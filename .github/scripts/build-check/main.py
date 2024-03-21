import os

print('Checking that the plugins were installed properly')

config = os.environ.get('CONFIG')
print("Checking plugin included: aws-wrapper")
assert 'aws-advanced-jdbc-wrapper' in config
