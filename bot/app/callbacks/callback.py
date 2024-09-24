from aiogram import Router, F
from aiogram.types import CallbackQuery

from app.data.database.requests import add_user, is_user_have_group
from app.data.text import greetings
from app.filters.is_registered import IsRegistered
from app.keyboards.chedule_viewer import Pagination, paginator
from app.keyboards.keyboard import menu, user_profile
from shedule.calendar_reader import CalendarReader

callback_router = Router()
callback_router.message.filter(IsRegistered())


@callback_router.callback_query(F.data == 'registration')
async def do_registration(callback: CallbackQuery):
    await add_user(callback.from_user.id)
    await callback.message.answer(
        'Вы успешно зарегистрированы!\nДля использования бота выберите в списке команд - \menu')


@callback_router.callback_query(F.data == 'menu')
async def return_to_menu(callback: CallbackQuery):
    await callback.message.answer(greetings, reply_markup=menu)


@callback_router.callback_query(F.data == 'subscribe_to_newsletter')
async def get_newsletter(callback: CallbackQuery):
    await callback.message.answer('Вы подписаны на рассылку')


@callback_router.callback_query(F.data == 'user_profile')
async def see_user_profile(callback: CallbackQuery):
    await is_user_have_group(callback.message.from_user.id)
    await callback.message.answer('Профиль пользователя', reply_markup=user_profile)


@callback_router.callback_query(F.data == 'edit_user_profile')
async def edit_user_profile(callback: CallbackQuery):
    await callback.message.answer('Редактирование профиля пользователя')
