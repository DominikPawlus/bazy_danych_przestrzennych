import smtplib, ssl, fme, datetime

sender_email = 'dompawlus@student.agh.edu.pl'
password = fme.macroValues['password']
receiver_email = fme.macroValues['email']
name = fme.macrovalues['name']
date = now.strftime("%d/%m/%Y %H:%M:%S")

message = "Drogi uzytkowniku "  + receiver_email + ", o godzinie " + date + " rozpoczeto przetwarzanie danych dla powiatu " + name

port = 587

context = ssl.create_default_context()

with smtplib.SMTP_SSL("poczta.agh.edu.pl", port, context=context) as server:
    server.login(sender_email, password)
    server.sendmail(sender_email, receiver_email, message)