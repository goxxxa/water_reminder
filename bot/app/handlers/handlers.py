from aiogram import Router, types
from aiogram.filters import Command, CommandStart
from aiogram.types import Message

from app.data.text import greetings
from app.filters.is_registered import IsRegistered
from app.keyboards.keyboard import menu, user_profile, web_app_test

handler_router = Router()
handler_router.message.filter(IsRegistered())


