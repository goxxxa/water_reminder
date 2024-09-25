from aiogram import Router, types
from aiogram.filters import Command, CommandStart
from aiogram.types import Message

from app.keyboards.keyboard import menu_keyboard


handler_router = Router()

@handler_router.message(CommandStart())
async def command_start(message: Message):
    await message.answer('Привет', reply_markup=menu_keyboard) 


