# Generated by Django 4.2.6 on 2023-11-18 07:04

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('inclass', '0018_alter_student_elected_courses'),
    ]

    operations = [
        migrations.AlterField(
            model_name='total_classes',
            name='batch',
            field=models.CharField(max_length=8),
        ),
    ]
