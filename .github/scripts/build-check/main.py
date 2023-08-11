import os

print('Checking that the plugins were installed properly')

config = os.environ.get('CONFIG')
print("Checking plugin included: aws-wrapper")
assert 'aws-advanced-jdbc-wrapper' in config
print("Checking plugin included: sts")
assert 'sts' in config
print("Checking plugin included: apache-client")
assert 'apache-client' in config
print("Checking db set to postgres")
assert 'kc.db =  postgres' in config
print("Checking health endpoint enabled")
assert 'kc.health-enabled =  true' in config
