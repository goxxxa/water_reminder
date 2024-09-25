from aiogram.types import InlineKeyboardMarkup, InlineKeyboardButton, ReplyKeyboardMarkup, KeyboardButton
from aiogram.types.web_app_info import WebAppInfo


menu_keyboard = ReplyKeyboardMarkup(keyboard=[
    [KeyboardButton(text='Открыть мини-приложение', web_app=WebAppInfo(url='https://luminarix.space'))]
], resize_keyboard=True)