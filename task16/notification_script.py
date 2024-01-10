import smtplib
from email.mime.text import MIMEText

yandex_password = ""
yandex_user = ""


def send_notification(subject, body, to_email):
    # Формирование письма
    msg = MIMEText(body)
    msg['Subject'] = subject
    msg['From'] = yandex_user
    msg['To'] = to_email

    try:
        # Отправка письма
        with smtplib.SMTP('smtp.yandex.ru', 587) as server:
            server.starttls()
            server.login(yandex_user, yandex_password)
            server.sendmail(yandex_user, to_email, msg.as_string())

        print("Уведомление успешно отправлено!")
    except Exception as e:
        print(f"Ошибка отправки уведомления: {e}")


if __name__ == "__main__":
    # Пример использования:
    subject = "А вот и уведомление о комите"
    body = "А вот и уведомление о комите"

    # Замените на вашу Yandex-почту
    to_email = "BenjaminBaton112@yandex.ru"

    send_notification(subject, body, to_email)
