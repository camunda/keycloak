import time
from keycloak import KeycloakAdmin
from keycloak import KeycloakOpenIDConnection
from keycloak.exceptions import KeycloakPostError

max_retries = 30
retry_delay = 5

print("Connecting to KeyCloak")
for attempt in range(1, max_retries + 1):
    try:
        keycloak_connection = KeycloakOpenIDConnection(
                                server_url="http://localhost:8080/",
                                username='admin',
                                password='admin',
                                realm_name="master")

        keycloak_admin = KeycloakAdmin(connection=keycloak_connection)
        break
    except KeycloakPostError as e:
        if "503" in str(e) and attempt < max_retries:
            print(f"Keycloak bootstrap in progress (attempt {attempt}/{max_retries}), retrying in {retry_delay}s...")
            time.sleep(retry_delay)
        else:
            raise
    except Exception as e:
        if attempt < max_retries:
            print(f"Connection failed (attempt {attempt}/{max_retries}): {e}, retrying in {retry_delay}s...")
            time.sleep(retry_delay)
        else:
            raise

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
