from openpyxl import load_workbook
from flask import Flask, render_template
import datetime

# Load the Excel file
wb = load_workbook('translations.xlsx')
sheet = wb.active

# Get the current date
today = datetime.date.today()
day = today.day

# Get the word, translation, and pronunciation for the current day
word = sheet.cell(row=day, column=1).value
translation = sheet.cell(row=day, column=2).value
pronunciation = sheet.cell(row=day, column=3).value
