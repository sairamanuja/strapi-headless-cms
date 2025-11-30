#!/bin/bash
# Force delete secrets that are scheduled for deletion

echo "Force deleting secrets from AWS Secrets Manager..."

secrets=(
  "strapi/db-password"
  "strapi/admin-jwt-secret"
  "strapi/api-token-salt"
  "strapi/app-keys"
  "strapi/jwt-secret"
  "strapi/transfer-token-salt"
  "strapi/encryption-key"
)

for secret in "${secrets[@]}"; do
  echo "Attempting to force delete: $secret"
  aws secretsmanager delete-secret \
    --secret-id "$secret" \
    --force-delete-without-recovery \
    --region ap-south-1 2>/dev/null || echo "  (secret may not exist or already deleted)"
done

echo ""
echo "Done! Now you can run: terraform apply"
