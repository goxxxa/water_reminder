from aiogram import Router, F
from aiogram.types import CallbackQuery
from app.keyboards.keyboard import menu_keyboard

callback_router = Router()

@callback_router.callback_query(F.data == 'start')
async def do_registration(callback: CallbackQuery):
    await callback.message.answer(
        'Привет! Я Water Bot.', reply_markup=menu_keyboard)


@callback_router.callback_query(F.data == 'app')
async def get_newsletter(callback: CallbackQuery):
    await callback.message.answer('Вы подписаны на рассылку')


@callback_router.callback_query(F.data == 'info')
async def edit_user_profile(callback: CallbackQuery):
    await callback.message.answer('Редактирование профиля пользователя')
