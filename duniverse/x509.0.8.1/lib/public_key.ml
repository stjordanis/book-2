type t = [
  | `RSA    of Nocrypto.Rsa.pub
  | `EC_pub of Asn.oid
]

module Asn = struct
  open Asn_grammars
  open Asn.S
  open Nocrypto

  let rsa_public_key =
    let f (n, e) = { Rsa.n ; e }
    and g ({ Rsa.n; e } : Rsa.pub) = (n, e) in
    map f g @@
    sequence2
      (required ~label:"modulus"        integer)
      (required ~label:"publicExponent" integer)

  let (rsa_public_of_cstruct, rsa_public_to_cstruct) =
    projections_of Asn.der rsa_public_key

  let rsa_pub_of_cs, rsa_pub_to_cs = project_exn rsa_public_key

  let reparse_pk = function
    | (Algorithm.RSA      , cs) -> `RSA (rsa_pub_of_cs cs)
    | (Algorithm.EC_pub id, _)  -> `EC_pub id
    | _ -> parse_error "unknown public key algorithm"

  let unparse_pk = function
    | `RSA pk    -> (Algorithm.RSA, rsa_pub_to_cs pk)
    | `EC_pub id -> (Algorithm.EC_pub id, Cstruct.create 0)

  let pk_info_der =
    map reparse_pk unparse_pk @@
    sequence2
      (required ~label:"algorithm" Algorithm.identifier)
      (required ~label:"subjectPK" bit_string_cs)

  let (pub_info_of_cstruct, pub_info_to_cstruct) =
    projections_of Asn.der pk_info_der
end

let id = function
  | `RSA p -> Nocrypto.Hash.digest `SHA1 (Asn.rsa_public_to_cstruct p)
  | `EC_pub _ -> Cstruct.empty

let fingerprint ?(hash = `SHA256) pub =
  Nocrypto.Hash.digest hash (Asn.pub_info_to_cstruct pub)

let encode_der = Asn.pub_info_to_cstruct

let decode_der cs = Asn_grammars.err_to_msg (Asn.pub_info_of_cstruct cs)

let decode_pem cs =
  let open Rresult.R.Infix in
  Pem.parse cs >>= fun data ->
  let pks = List.filter (fun (t, _) -> String.equal "PUBLIC KEY" t) data in
  Pem.foldM (fun (_, k) -> decode_der k) pks >>=
  Pem.exactly_one ~what:"public key"

let encode_pem v =
  Pem.unparse ~tag:"PUBLIC KEY" (encode_der v)
