module.exports = ({ env }) => ({
  upload: {
    config: {
      provider: '@strapi/provider-upload-aws-s3',
      providerOptions: {
        baseUrl: env('AWS_S3_BASE_URL'),
        s3Options: {
          // When running on ECS with IAM role, credentials are automatically picked up
          // Only use explicit credentials if AWS_ACCESS_KEY_ID is set
          ...(env('AWS_ACCESS_KEY_ID') && {
            credentials: {
              accessKeyId: env('AWS_ACCESS_KEY_ID'),
              secretAccessKey: env('AWS_ACCESS_SECRET'),
            },
          }),
          region: env('AWS_REGION', 'ap-south-1'),
          params: {
            Bucket: env('AWS_S3_BUCKET'),
            ACL: null,
          },
        },
      },
      actionOptions: {
        upload: {
          ACL: null,
        },
        uploadStream: {
          ACL: null,
        },
        delete: {},
      },
    },
  },
});
