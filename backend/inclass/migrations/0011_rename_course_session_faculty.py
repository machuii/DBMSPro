# Generated by Django 4.2.6 on 2023-11-14 13:03

from django.db import migrations


class Migration(migrations.Migration):

    dependencies = [
        ('inclass', '0010_alter_session_course'),
    ]

    operations = [
        migrations.RenameField(
            model_name='session',
            old_name='course',
            new_name='faculty',
        ),
    ]