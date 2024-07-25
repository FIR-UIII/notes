# requests
```
GET

payload = {'key1': 'value1', 'key2': 'value2'}
response = requests.get('http://.com', params=payload)
print(response.text)


POST
payload = {'key1': 'value1', 'key2': 'value2'}
response = requests.post('http://httpbin.org/post', data=payload)



```
