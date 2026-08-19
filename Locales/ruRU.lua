-- ♡ Contributors: ZamestoTV


if GetLocale() ~= "ruRU" then return end

local env = select(2, ...)
local L = env.L

-- Keybinds
BINDING_HEADER_MANIFOLD = "Manifold"
BINDING_HEADER_MANIFOLD_HOUSING = "Жильё (Manifold)"
PREFACE_MANIFOLD_HOUSING_EXPERTDECOR_BINDINGS = "Привязки продвинутого режима для точной манипуляции декором с помощью колёсика мыши."
BINDING_NAME_MANIFOLD_HOUSING_EXPERTDECORPRECISE_TRANSLATE_X = "Точная перемещение (X)"
BINDING_NAME_MANIFOLD_HOUSING_EXPERTDECORPRECISE_TRANSLATE_Y = "Точная перемещение (Y)"
BINDING_NAME_MANIFOLD_HOUSING_EXPERTDECORPRECISE_TRANSLATE_Z = "Точная перемещение (Z)"
BINDING_NAME_MANIFOLD_HOUSING_EXPERTDECORPRECISE_ROTATE = "Точное вращение"
BINDING_NAME_MANIFOLD_HOUSING_EXPERTDECORPRECISE_SCALE = "Точное масштабирование"


-- OptionsFrame
L["OPTIONS_HEADING"] = "Переключение настроек с помощью /manifold"
L["OPTIONS_BUTTON"] = "Открыть настройки"
L["OPTIONS_ACTIVATE"] = "Активировать"
L["OPTIONS_DEACTIVATE"] = "Деактивировать"
L["OPTIONS_ALWAYS_ACTIVATED"] = "Всегда активно"
L["OPTIONS_NEW"] = "Новое"
L["OPTIONS_SEARCH"] = "Поиск"
L["OPTIONS_ACTION_PREFIX"] = "<Нажмите, чтобы "
L["OPTIONS_ACTION_SUFFIX"] = ">"
L["OPTIONS_ALT_ACTION_PREFIX"] = "<ПКМ, чтобы "
L["OPTIONS_ALT_ACTION_SUFFIX"] = ">"

-- Modules
L["HOUSING"] = "Жильё"
L["HOUSING_DECOR_MERCHANT"] = "Торговец декором"
L["HOUSING_DECOR_MERCHANT_DESCRIPTION"] = "Автоматически подтверждает дорогие покупки и позволяет покупать оптом (Shift+ПКМ) у торговцев декором."
L["HOUSING_HOUSE_CHEST"] = "Постоянная панель сундука дома"
L["HOUSING_HOUSE_CHEST_DESCRIPTION"] = "Сохраняет панель сундука дома видимой во всех режимах редактора жилья."
L["HOUSING_PLACED_DECOR_LIST"] = "Список размещённого декора"
L["HOUSING_PLACED_DECOR_LIST_DESCRIPTION"] = "Включает изменение размера списка размещённого декора и показывает стоимость размещения для каждого предмета."
L["HOUSING_DECOR_TOOLTIP"] = "Подсвеченная подсказка декора"
L["HOUSING_DECOR_TOOLTIP_DESCRIPTION"] = "Показывает подсказку с названием и стоимостью размещения при наведении на декор."
L["HOUSING_DECOR_TOOLTIP_SELECT"] = "ЛКМ - Выбрать"
L["HOUSING_DECOR_TOOLTIP_REMOVE"] = "ЛКМ - Убрать"
L["HOUSING_PRECISE_MOVEMENT"] = "(Продвинутый режим) Точное перемещение"
L["HOUSING_PRECISE_MOVEMENT_DESCRIPTION"] = "Позволяет точно перемещать, вращать и масштабировать декор, удерживая соответствующую привязку и прокручивая колёсико мыши."
L["HOUSING_PRECISE_MOVEMENT_ALT_ACTION"] = "просмотреть назначение клавиш"
L["HOUSING_PRECISE_MOVEMENT_MOUSE_WHEEL"] = "Колёсико мыши"
L["HOUSING_PRECISE_MOVEMENT_X"] = "Точное перемещение (X)"
L["HOUSING_PRECISE_MOVEMENT_Y"] = "Точное перемещение (Y)"
L["HOUSING_PRECISE_MOVEMENT_Z"] = "Точное перемещение (Z)"
L["HOUSING_PRECISE_MOVEMENT_ROTATE"] = "Точное вращение"
L["HOUSING_PRECISE_MOVEMENT_SCALE"] = "Точное масштабирование"

L["TOOLTIP"] = "Подсказки"
L["TOOLTIP_QUEST_DETAIL"] = "Подробная подсказка задания"
L["TOOLTIP_QUEST_DETAIL_DESCRIPTION"] = "Показывает подробную информацию о задании (цели, награды и др.) при наведении на задания в трекере и журнале."
L["TOOLTIP_EXPERIENCE_BAR"] = "Подсказка полосы опыта"
L["TOOLTIP_EXPERIENCE_BAR_DESCRIPTION"] = "Расширяет подсказку полосы опыта дополнительными деталями."
L["TOOLTIP_EXPERIENCE_BAR_STATISTICS"] = "Статистика"
L["TOOLTIP_EXPERIENCE_BAR_EXPERIENCE_PER_HOUR"] = "%s опыта в час."
L["TOOLTIP_EXPERIENCE_BAR_UNTIL_NEXT_LEVEL"] = "%s до следующего уровня."
L["TOOLTIP_EXPERIENCE_BAR_UNTIL_MAX_LEVEL"] = "%s до максимального уровня."

L["LOOT"] = "Добыча"
L["LOOT_ALERT_POPUP"] = "Быстрое экипирование из уведомлений"
L["LOOT_ALERT_POPUP_DESCRIPTION"] = "Позволяет мгновенно экипировать предметы из всплывающих уведомлений о добыче (ЛКМ)."
L["LOOT_ALERT_POPUP_EQUIP"] = "Экипировать"
L["LOOT_ALERT_POPUP_EQUIPPING"] = "Экипировка..."
L["LOOT_ALERT_POPUP_EQUIPPED"] = "Экипировано"
L["LOOT_ALERT_POPUP_COMBAT"] = "В бою"
L["LOOT_ALERT_POPUP_VENDOR"] = "У торговца"

L["EVENTS"] = "События"

L["ACHIEVEMENTS"] = "Достижения"
L["ACHIEVEMENTS_ACHIEVEMENT_LINK"] = "Ссылка на достижение"
L["ACHIEVEMENTS_ACHIEVEMENT_LINK_DESCRIPTION"] = "Используйте Ctrl+ЛКМ по ссылке, чтобы открыть её в окне достижений."

L["TRANSMOG"] = "Трансмогрификация"
L["TRANSMOG_DRESSING_ROOM"] = "Примерочная"
L["TRANSMOG_DRESSING_ROOM_DESCRIPTION"] = "Позволяет свободно перемещать и масштабировать рамку примерочной."

-- Contributors
L["CONTRIBUTORS_HUCHANG47"] = "huchang47"
L["CONTRIBUTORS_HUCHANG47_DESCRIPTION"] = "Переводчик - на упрощённый китайский и традиционный китайский"
L["CONTRIBUTORS_ZAMESTOTV"] = "ZamestoTV"
L["CONTRIBUTORS_ZAMESTOTV_DESCRIPTION"] = "Переводчик - на русский"
