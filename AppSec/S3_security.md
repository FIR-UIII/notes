```
aws s3 ls s3://prism-uploads/ --no-sign-request

aws s3api put-public-access-block \
  --bucket prism-uploads \
  --public-access-block-configuration \
    BlockPublicAcls=true,\
    IgnorePublicAcls=true,\
    BlockPublicPolicy=true,\
    RestrictPublicBuckets=true
```