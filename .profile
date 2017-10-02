export GOOGLE_APPLICATION_CREDENTIALS="$(pwd)/tmp/google_application_credentials.json"
mkdir -p $(dirname "$GOOGLE_APPLICATION_CREDENTIALS")
echo "$GOOGLE_CREDENTIAL_BLOB" | base64 --decode -o "$GOOGLE_APPLICATION_CREDENTIALS"
