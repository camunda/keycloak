from keycloak import KeycloakAdmin
from keycloak import KeycloakOpenIDConnection

print("Connecting to KeyCloak")
keycloak_connection = KeycloakOpenIDConnection(
                        server_url="http://localhost:8080/",
                        username='admin',
                        password='admin',
                        realm_name="master")

keycloak_admin = KeycloakAdmin(connection=keycloak_connection)

print("Checking that only 1 user exists")
count_users = keycloak_admin.users_count()
assert count_users == 1

print("Checking that existing user is admin")
users = keycloak_admin.get_users({})
assert 'admin' in users[0]['username']

print("Adding new User")
new_user = keycloak_admin.create_user({"email": "example@example.com",
                                       "username": "example@example.com",
                                       "enabled": True,
                                       "firstName": "Example",
                                       "lastName": "Example"})

print("Checking that new user is registered")
count_users = keycloak_admin.users_count()
assert count_users == 2

print("Deleting created User")
response = keycloak_admin.delete_user(user_id=new_user)
count_users = keycloak_admin.users_count()
assert count_users == 1
