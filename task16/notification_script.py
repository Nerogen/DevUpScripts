import smtplib
from email.mime.text import MIMEText

yandex_password = ""
yandex_user = ""


def send_notification(subject, body, to_email):
    msg = MIMEText(body)
    msg['Subject'] = subject
    msg['From'] = yandex_user
    msg['To'] = to_email

    try:
        with smtplib.SMTP('smtp.yandex.ru', 587) as server:
            server.starttls()
            server.login(yandex_user, yandex_password)
            server.sendmail(yandex_user, to_email, msg.as_string())

        print("Уведомление успешно отправлено!")
    except Exception as e:
        print(f"Ошибка отправки уведомления: {e}")


def main():
    subject = "А вот и уведомление о комите"
    body = "А вот и уведомление о комите"
    to_email = "BenjaminBaton112@yandex.ru"

    send_notification(subject, body, to_email)


if __name__ == "__main__":
    main()
