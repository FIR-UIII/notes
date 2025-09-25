```
True negative | False positive
--------------|----------------
False negative| True positive

TN - анализатор верно не нашел проблему, ее нет на самом деле
FP - анализатор нашел проблему, но ее нет на самом деле
FN - анализатор не нашел проблему, но она была в коде на самом деле
TP - анализатор верно нашел проблему, она была в коде на самом деле

[V] - Vulnerable function
[S] - Safe function
```

### SQLi
```
# [V]  string concatenation
String custQuery = SELECT custName, address1 FROM cust_table WHERE custID= ‘“ + request.GetParameter(“id”) + ““
# [S] parametrized queries
String query = "SELECT account_number, account_balance FROM customer_data WHERE account_owner_id = ?"
PreparedStatement pstmt = connection.prepareStatement( query );
# [S] ORM: Spring Data JPA, Spring Data JDBC
String firstName = this.jdbcTemplate.queryForObject(
    "SELECT first_name FROM users WHERE id = ?",
    String.class, 8);
# [S] no user input, hardcoded SQL
const safedata = "foo"
String custQuery = SELECT custName, address1 FROM cust_table WHERE custID= ‘“ + safedata + ““
```
