# DAC
User1 > Permissions (read, write) > Resource<br>
User2 > Permissions (write) > Resource<br>
User3 > Permissions (none) > Resource<br>

# RBAC
User1 \ <br>
User2  -> Role (customer) > Permissions (read, write) > Resource<br>
User3 /<br>

`+` Опираются на текущий процесс, в котором можно выделить общую роль для группы пользователей. Мы создает абстакцию над процессом.<br>
`-` Если нет процесса или пользователей нельзя группировать - возникает множество ролей
Нет кастомизации по параметрам<br>


# ABAC
Resource = Attribute<br>

User1 = Attribute \ <br>
User2 = Attribute  -> Policy (permit "customer" IF "12PM" OR "read_data" to Resource1) > Action (read, write) > Resource<br>
User3 = Attribute / <br>

Attribute:<br>
- IP<br>
- Position<br>
- Departament<br>
- Access level to confidential info (L1, L2, L3)<br>
- Time access<br>

`+` Более гибкая система. Зависит от аттрибутов, которые можно гибко настраивать при изменении процесса. Может работать вместе с RBAC<br>
`-` Сложна для реализации<br>

Frameworks ABAC: XACML, ALFA <br>

```
class User:
    def __init__(self, name, department):
        self.name = name
        self.department = department
        self.attributes = {"department": department}

class Resource:
    def __init__(self, name, owner):
        self.name = name
        self.owner = owner
        self.attributes = {"owner": owner}

class Policy:
    def __init__(self, subject, action, object_, condition=None):
        self.subject = subject
        self.action = action
        self.object_ = object_
        self.condition = condition

def evaluate_policy(user, resource, policy):
    # Evaluate the condition if it exists
    if policy.condition:
        if not eval(policy.condition):
            return False
    
    # Check if the user has the required attribute
    if isinstance(policy.subject, str):
        if policy.subject not in user.attributes:
            return False
    
    # Check if the resource has the required attribute
    if isinstance(policy.object_, str):
        if policy.object_ not in resource.attributes:
            return False
    
    # Check if the action matches
    if policy.action != "read":
        return False
    
    return True

def check_access(user, resource, action="read"):
    policies = [
        Policy("department", "read", "resource"),
        Policy("owner", "write", "resource")
    ]
    
    for policy in policies:
        if policy.action == action:
            if evaluate_policy(user, resource, policy):
                print(f"{user.name} can {action} {resource.name}")
                return True
    
    print(f"{user.name} cannot {action} {resource.name}")
    return False

# Sample usage
user1 = User("Alice", "HR")
user2 = User("Bob", "IT")

resource1 = Resource("Employee Data", "HR")
resource2 = Resource("Network Configuration", "IT")

check_access(user1, resource1, "read")
check_access(user1, resource2, "read")
check_access(user2, resource1, "read")
check_access(user2, resource2, "write")
```
