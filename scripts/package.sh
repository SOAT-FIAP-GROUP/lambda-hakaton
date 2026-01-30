#!/usr/bin/env bash
set -e

# Clean old zips
rm -f lambda/*/*.zip

# For signup and signin (no external deps)
for fn in signup signin; do
  cd lambda/$fn
  zip -r9 ../$fn.zip .
  cd ../..
done

# For "me" we need PyJWT
cd lambda/get_user
pip install --target . pyjwt cryptography
zip -r9 ../get_user.zip .
cd ../..
