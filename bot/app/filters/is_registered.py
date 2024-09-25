from aiogram.filters import BaseFilter
from aiogram.types import Message


class IsRegistered(BaseFilter):
    async def __call__(self, message: Message):
        if message.from_user.id in await get_users_ids():
            return True
