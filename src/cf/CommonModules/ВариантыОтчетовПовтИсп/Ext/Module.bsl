﻿///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2019, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область СлужебныйПрограммныйИнтерфейс

// Формирует список отчетов конфигурации, доступных текущему пользователю.
// Его следует использовать во всех запросах к таблице
// справочника "ВариантыОтчетов" как отбор по реквизиту "Отчет".
//
// Возвращаемое значение:
//   Массив - ссылки отчетов, доступных текущему пользователю.
//            Тип элементов см. в реквизите Справочники.ВариантыОтчетов.Реквизиты.Отчет.
//
Функция ДоступныеОтчеты(ПроверятьФункциональныеОпции = Истина) Экспорт
	
	Результат = Новый Массив;
	ПолныеИменаОтчетов = Новый Массив;
	
	ПоУмолчаниюВсеПодключены = Неопределено;
	Для Каждого ОтчетМетаданные Из Метаданные.Отчеты Цикл
		Если Не ПравоДоступа("Просмотр", ОтчетМетаданные)
			Или Не ВариантыОтчетов.ОтчетПодключенКХранилищу(ОтчетМетаданные, ПоУмолчаниюВсеПодключены) Тогда
			Продолжить;
		КонецЕсли;
		Если ПроверятьФункциональныеОпции
			И Не ОбщегоНазначения.ОбъектМетаданныхДоступенПоФункциональнымОпциям(ОтчетМетаданные) Тогда
			Продолжить;
		КонецЕсли;
		ПолныеИменаОтчетов.Добавить(ОтчетМетаданные.ПолноеИмя());
	КонецЦикла;
	
	ИдентификаторыОтчетов = ОбщегоНазначения.ИдентификаторыОбъектовМетаданных(ПолныеИменаОтчетов);
	Для Каждого ИдентификаторОтчета Из ИдентификаторыОтчетов Цикл
		Результат.Добавить(ИдентификаторОтчета.Значение);
	КонецЦикла;
	
	Возврат Новый ФиксированныйМассив(Результат);
	
КонецФункции

// Формирует список вариантов отчетов конфигурации, недоступных текущему пользователю по функциональным опциям.
// Следует использовать во всех запросах к таблице
// справочника "ВариантыОтчетов" как исключающий отбор по реквизиту "ПредопределенныйВариант".
//
// Возвращаемое значение:
//   Массив - варианты отчетов, которые отключены по функциональным опциям.
//            Тип элементов - СправочникСсылка.ПредопределенныеВариантыОтчетов,
//            СправочникСсылка.ПредопределенныеВариантыОтчетовРасширений.
//
Функция ОтключенныеВариантыПрограммы() Экспорт
	
	Возврат Новый ФиксированныйМассив(ВариантыОтчетов.ОтключенныеВариантыОтчетов());
	
КонецФункции

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

// Формирует дерево подсистем, доступных текущему пользователю.
//
// Возвращаемое значение:
//   ДеревоЗначений -Результат - ДеревоЗначений -
//       * РазделСсылка - СправочникСсылка.ИдентификаторыОбъектовМетаданных - Ссылка раздела.
//       * Ссылка       - СправочникСсылка.ИдентификаторыОбъектовМетаданных - Ссылка подсистемы.
//       * Имя           - Строка - Имя подсистемы.
//       * ПолноеИмя     - Строка - Полное имя подсистемы.
//       * Представление - Строка - Представление подсистемы.
//       * Приоритет     - Строка - Приоритет подсистемы.
//
Функция ПодсистемыТекущегоПользователя() Экспорт
	
	ТипыИдентификатора = Новый Массив;
	ТипыИдентификатора.Добавить(Тип("СправочникСсылка.ИдентификаторыОбъектовМетаданных"));
	ТипыИдентификатора.Добавить(Тип("СправочникСсылка.ИдентификаторыОбъектовРасширений"));
	
	Результат = Новый ДеревоЗначений;
	Результат.Колонки.Добавить("Ссылка",              Новый ОписаниеТипов(ТипыИдентификатора));
	Результат.Колонки.Добавить("Имя",                 ВариантыОтчетов.ОписаниеТиповСтрока(150));
	Результат.Колонки.Добавить("ПолноеИмя",           ВариантыОтчетов.ОписаниеТиповСтрока(510));
	Результат.Колонки.Добавить("Представление",       ВариантыОтчетов.ОписаниеТиповСтрока(150));
	Результат.Колонки.Добавить("РазделСсылка",        Новый ОписаниеТипов(ТипыИдентификатора));
	Результат.Колонки.Добавить("РазделПолноеИмя",     ВариантыОтчетов.ОписаниеТиповСтрока(510));
	Результат.Колонки.Добавить("Приоритет",           ВариантыОтчетов.ОписаниеТиповСтрока(100));
	Результат.Колонки.Добавить("ПолноеПредставление", ВариантыОтчетов.ОписаниеТиповСтрока(300));
	
	КорневаяСтрока = Результат.Строки.Добавить();
	КорневаяСтрока.Ссылка = Справочники.ИдентификаторыОбъектовМетаданных.ПустаяСсылка();
	КорневаяСтрока.Представление = НСтр("ru = 'Все разделы'");
	
	ПолныеИменаПодсистем = Новый Массив;
	ПолныеИменаСтрокДерева = Новый Соответствие;
	
	ИдентификаторНачальнойСтраницы = ВариантыОтчетовКлиентСервер.ИдентификаторНачальнойСтраницы();
	СписокРазделов = ВариантыОтчетов.СписокРазделов();
	
	Приоритет = 0;
	Для Каждого ЭлементСписка Из СписокРазделов Цикл
		
		РазделМетаданные = ЭлементСписка.Значение;
		Если НЕ (ТипЗнч(РазделМетаданные) = Тип("ОбъектМетаданных") И СтрНачинаетсяС(РазделМетаданные.ПолноеИмя(), "Подсистема"))
			И НЕ (ТипЗнч(РазделМетаданные) = Тип("Строка") И РазделМетаданные = ИдентификаторНачальнойСтраницы) Тогда
			
			ВызватьИсключение НСтр("ru = 'Некорректно определены значения разделов в процедуре ВариантыОтчетовПереопределяемый.ОпределитьРазделыСВариантамиОтчетов'");
			
		КонецЕсли;
		
		Если ЗначениеЗаполнено(ЭлементСписка.Представление) Тогда
			ШаблонЗаголовка = ЭлементСписка.Представление;
		Иначе
			ШаблонЗаголовка = НСтр("ru = 'Отчеты раздела ""%1""'");
		КонецЕсли;
		
		ЭтоНачальнаяСтраница = (РазделМетаданные = ИдентификаторНачальнойСтраницы);
		
		Если Не ЭтоНачальнаяСтраница
			И (Не ПравоДоступа("Просмотр", РазделМетаданные)
				Или Не ОбщегоНазначения.ОбъектМетаданныхДоступенПоФункциональнымОпциям(РазделМетаданные)) Тогда
			Продолжить; // Подсистема не доступна по ФО или по правам.
		КонецЕсли;
		
		СтрокаДерева = КорневаяСтрока.Строки.Добавить();
		Если ЭтоНачальнаяСтраница Тогда
			СтрокаДерева.Имя           = ИдентификаторНачальнойСтраницы;
			СтрокаДерева.ПолноеИмя     = ИдентификаторНачальнойСтраницы;
			СтрокаДерева.Представление = СтандартныеПодсистемыСервер.ПредставлениеНачальнойСтраницы();
		Иначе
			СтрокаДерева.Имя           = РазделМетаданные.Имя;
			СтрокаДерева.ПолноеИмя     = РазделМетаданные.ПолноеИмя();
			СтрокаДерева.Представление = РазделМетаданные.Представление();
		КонецЕсли;
		
		ПолныеИменаПодсистем.Добавить(СтрокаДерева.ПолноеИмя);
		
		Если ПолныеИменаСтрокДерева[СтрокаДерева.ПолноеИмя] = Неопределено Тогда
			ПолныеИменаСтрокДерева.Вставить(СтрокаДерева.ПолноеИмя, СтрокаДерева);
		Иначе
			ПолныеИменаСтрокДерева.Вставить(СтрокаДерева.ПолноеИмя, Истина); // Требуется поиск по дереву.
		КонецЕсли;
		
		СтрокаДерева.РазделПолноеИмя = СтрокаДерева.ПолноеИмя;
		СтрокаДерева.ПолноеПредставление = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			ШаблонЗаголовка,
			СтрокаДерева.Представление);
		
		Приоритет = Приоритет + 1;
		СтрокаДерева.Приоритет = Формат(Приоритет, "ЧЦ=4; ЧДЦ=0; ЧВН=; ЧГ=0");
		Если Не ЭтоНачальнаяСтраница Тогда
			ДобавитьПодсистемыТекущегоПользователя(СтрокаДерева, РазделМетаданные, ПолныеИменаПодсистем, ПолныеИменаСтрокДерева);
		КонецЕсли;
	КонецЦикла;
	
	СсылкиПодсистем = ОбщегоНазначения.ИдентификаторыОбъектовМетаданных(ПолныеИменаПодсистем);
	Для Каждого КлючИЗначение Из СсылкиПодсистем Цикл
		СтрокаДерева = ПолныеИменаСтрокДерева[КлючИЗначение.Ключ];
		Если СтрокаДерева = Истина Тогда // Требуется поиск по дереву.
			Найденные = Результат.Строки.НайтиСтроки(Новый Структура("ПолноеИмя", КлючИЗначение.Ключ), Истина);
			Для Каждого СтрокаДерева Из Найденные Цикл
				СтрокаДерева.Ссылка = КлючИЗначение.Значение;
				СтрокаДерева.РазделСсылка = СсылкиПодсистем[СтрокаДерева.РазделПолноеИмя];
			КонецЦикла;
		Иначе
			СтрокаДерева.Ссылка = КлючИЗначение.Значение;
			СтрокаДерева.РазделСсылка = СсылкиПодсистем[СтрокаДерева.РазделПолноеИмя];
		КонецЕсли;
	КонецЦикла;
	
	ПолныеИменаСтрокДерева.Очистить();
	
	Возврат Результат;
	
КонецФункции

Процедура ДобавитьПодсистемыТекущегоПользователя(СтрокаРодителя, МетаданныеРодителя, ПолныеИменаПодсистем, ПолныеИменаСтрокДерева)
	
	ПриоритетРодителя = СтрокаРодителя.Приоритет;
	
	Приоритет = 0;
	Для Каждого ПодсистемаМетаданные Из МетаданныеРодителя.Подсистемы Цикл
		Приоритет = Приоритет + 1;
		
		Если Не ПодсистемаМетаданные.ВключатьВКомандныйИнтерфейс
			Или Не ПравоДоступа("Просмотр", ПодсистемаМетаданные)
			Или Не ОбщегоНазначения.ОбъектМетаданныхДоступенПоФункциональнымОпциям(ПодсистемаМетаданные) Тогда
			Продолжить; // Подсистема не доступна по ФО или по правам.
		КонецЕсли;
		
		СтрокаДерева = СтрокаРодителя.Строки.Добавить();
		СтрокаДерева.Имя           = ПодсистемаМетаданные.Имя;
		СтрокаДерева.ПолноеИмя     = ПодсистемаМетаданные.ПолноеИмя();
		СтрокаДерева.Представление = ПодсистемаМетаданные.Представление();
		ПолныеИменаПодсистем.Добавить(СтрокаДерева.ПолноеИмя);
		Если ПолныеИменаСтрокДерева[СтрокаДерева.ПолноеИмя] = Неопределено Тогда
			ПолныеИменаСтрокДерева.Вставить(СтрокаДерева.ПолноеИмя, СтрокаДерева);
		Иначе
			ПолныеИменаСтрокДерева.Вставить(СтрокаДерева.ПолноеИмя, Истина); // Требуется поиск по дереву.
		КонецЕсли;
		СтрокаДерева.РазделПолноеИмя = СтрокаРодителя.РазделПолноеИмя;
		
		Если СтрДлина(ПриоритетРодителя) > 12 Тогда
			СтрокаДерева.ПолноеПредставление = СтрокаРодителя.Представление + ": " + СтрокаДерева.Представление;
		Иначе
			СтрокаДерева.ПолноеПредставление = СтрокаДерева.Представление;
		КонецЕсли;
		СтрокаДерева.Приоритет = ПриоритетРодителя + Формат(Приоритет, "ЧЦ=4; ЧДЦ=0; ЧВН=; ЧГ=0");
		
		ДобавитьПодсистемыТекущегоПользователя(СтрокаДерева, ПодсистемаМетаданные, ПолныеИменаПодсистем, ПолныеИменаСтрокДерева);
	КонецЦикла;
	
КонецПроцедуры

Функция ПредставленияПодсистем() Экспорт
	
	ТипыИдентификатора = Новый Массив;
	ТипыИдентификатора.Добавить(Тип("СправочникСсылка.ИдентификаторыОбъектовМетаданных"));
	ТипыИдентификатора.Добавить(Тип("СправочникСсылка.ИдентификаторыОбъектовРасширений"));
	
	Результат = Новый ТаблицаЗначений;
	Результат.Колонки.Добавить("Ссылка",        Новый ОписаниеТипов(ТипыИдентификатора));
	Результат.Колонки.Добавить("ПолноеИмя",     ВариантыОтчетов.ОписаниеТиповСтрока(510));
	Результат.Колонки.Добавить("Представление", ВариантыОтчетов.ОписаниеТиповСтрока(150));
	
	ИдентификаторНачальнойСтраницы = ВариантыОтчетовКлиентСервер.ИдентификаторНачальнойСтраницы();
	Для Каждого Раздел Из ВариантыОтчетов.СписокРазделов() Цикл
		
		РазделМетаданные = Раздел.Значение;
		Если НЕ (ТипЗнч(РазделМетаданные) = Тип("ОбъектМетаданных") И СтрНачинаетсяС(РазделМетаданные.ПолноеИмя(), "Подсистема"))
			И НЕ (ТипЗнч(РазделМетаданные) = Тип("Строка") И РазделМетаданные = ИдентификаторНачальнойСтраницы) Тогда
			ВызватьИсключение НСтр("ru = 'Некорректно определены значения разделов в процедуре ВариантыОтчетовПереопределяемый.ОпределитьРазделыСВариантамиОтчетов'");
		КонецЕсли;
		
		ЭтоНачальнаяСтраница = (РазделМетаданные = ИдентификаторНачальнойСтраницы);
		Если Не ЭтоНачальнаяСтраница
			И (Не ПравоДоступа("Просмотр", РазделМетаданные)
				Или Не ОбщегоНазначения.ОбъектМетаданныхДоступенПоФункциональнымОпциям(РазделМетаданные)) Тогда
			Продолжить; 
		КонецЕсли;
		
		СтрокаТаблицы = Результат.Добавить();
		Если ЭтоНачальнаяСтраница Тогда
			СтрокаТаблицы.ПолноеИмя     = ИдентификаторНачальнойСтраницы;
			СтрокаТаблицы.Представление = СтандартныеПодсистемыСервер.ПредставлениеНачальнойСтраницы();
		Иначе
			СтрокаТаблицы.ПолноеИмя     = РазделМетаданные.ПолноеИмя();
			СтрокаТаблицы.Представление = РазделМетаданные.Представление();
		КонецЕсли;
		СтрокаТаблицы.Ссылка = Справочники.ИдентификаторыОбъектовМетаданных.ПустаяСсылка();
		Если Не ЭтоНачальнаяСтраница Тогда
			ДобавитьПодсистемы(Результат, РазделМетаданные);
		КонецЕсли;
	КонецЦикла;
	
	Результат.Индексы.Добавить("ПолноеИмя");
	
	СсылкиПодсистем = ОбщегоНазначения.ИдентификаторыОбъектовМетаданных(Результат.ВыгрузитьКолонку("ПолноеИмя"), Ложь);
	Для Каждого СсылкаПодсистемы Из СсылкиПодсистем Цикл
		СтрокаТаблицы = Результат.Найти(СсылкаПодсистемы.Ключ, "ПолноеИмя");
		Если СтрокаТаблицы <> Неопределено Тогда 
			СтрокаТаблицы.Ссылка = СсылкаПодсистемы.Значение;
		КонецЕсли;
	КонецЦикла;
	
	Возврат Результат;
	
КонецФункции

Процедура ДобавитьПодсистемы(ТаблицаПодсистем, МетаданныеРодителя)

	Для Каждого ПодсистемаМетаданные Из МетаданныеРодителя.Подсистемы Цикл
		
		Если Не ПодсистемаМетаданные.ВключатьВКомандныйИнтерфейс
			Или Не ПравоДоступа("Просмотр", ПодсистемаМетаданные)
			Или Не ОбщегоНазначения.ОбъектМетаданныхДоступенПоФункциональнымОпциям(ПодсистемаМетаданные) Тогда
			Продолжить; 
		КонецЕсли;
		
		СтрокаТаблицы = ТаблицаПодсистем.Добавить();
		СтрокаТаблицы.ПолноеИмя = ПодсистемаМетаданные.ПолноеИмя();
		СтрокаТаблицы.Представление = ПодсистемаМетаданные.Представление();
		СтрокаТаблицы.Ссылка = Справочники.ИдентификаторыОбъектовМетаданных.ПустаяСсылка();
		ДобавитьПодсистемы(ТаблицаПодсистем, ПодсистемаМетаданные);
	КонецЦикла;
	
КонецПроцедуры

// Возвращает Истина если у пользователя есть право чтения вариантов отчетов.
Функция ПравоЧтения() Экспорт
	
	Возврат ПравоДоступа("Чтение", Метаданные.Справочники.ВариантыОтчетов);
	
КонецФункции

// Возвращает Истина если у пользователя есть право на сохранение вариантов отчетов.
Функция ПравоДобавления() Экспорт
	
	Возврат ПравоДоступа("СохранениеДанныхПользователя", Метаданные)
		И ПравоДоступа("Добавление", Метаданные.Справочники.ВариантыОтчетов);
	
КонецФункции

// Параметры подсистемы, закэшированные при обновлении (см. ВариантыОтчетов.ЗаписатьПараметрыВариантовОтчетов).
//
// Возвращаемое значение:
//   Структура - со свойствами:
//     * ТаблицаФункциональныхОпций - ТаблицаЗначений - связь функциональных опций и предопределенных вариантов отчетов:
//       ** Отчет - СправочникСсылка.ИдентификаторыОбъектовМетаданных
//       ** ПредопределенныйВариант - СправочникСсылка.ПредопределенныеВариантыОтчетов
//       ** ИмяФункциональнойОпции - Строка
//     * ОтчетыСНастройками - Массив из СправочникСсылка.ИдентификаторыОбъектовМетаданных - отчеты,
//          в модуле объекта которых размещены процедуры интеграции с общей формой отчета.
// 
Функция Параметры() Экспорт
	
	ПолноеИмяПодсистемы = ВариантыОтчетовКлиентСервер.ПолноеИмяПодсистемы();
	Параметры = СтандартныеПодсистемыСервер.ПараметрРаботыПрограммы(ПолноеИмяПодсистемы);
	Если Параметры = Неопределено Тогда
		ВариантыОтчетов.ОперативноеОбновлениеОбщихДанныхКонфигурации(Новый Структура("РазделенныеОбработчики"));
		Параметры = СтандартныеПодсистемыСервер.ПараметрРаботыПрограммы(ПолноеИмяПодсистемы);
	КонецЕсли;
	
	Если ЗначениеЗаполнено(ПараметрыСеанса.ВерсияРасширений) Тогда
		ПараметрыРасширений = СтандартныеПодсистемыСервер.ПараметрРаботыРасширения(ПолноеИмяПодсистемы);
		Если ПараметрыРасширений = Неопределено Тогда
			УстановитьОтключениеБезопасногоРежима(Истина);
			УстановитьПривилегированныйРежим(Истина);
			ВариантыОтчетов.ПриЗаполненииВсехПараметровРаботыРасширений();
			УстановитьПривилегированныйРежим(Ложь);
			УстановитьОтключениеБезопасногоРежима(Ложь);
			ПараметрыРасширений = СтандартныеПодсистемыСервер.ПараметрРаботыРасширения(ПолноеИмяПодсистемы);
		КонецЕсли;
		
		Если ПараметрыРасширений <> Неопределено Тогда
			ОбщегоНазначенияКлиентСервер.ДополнитьМассив(Параметры.ОтчетыСНастройками, ПараметрыРасширений.ОтчетыСНастройками);
			ОбщегоНазначенияКлиентСервер.ДополнитьТаблицу(Параметры.ТаблицаФункциональныхОпций, ПараметрыРасширений.ТаблицаФункциональныхОпций);
		КонецЕсли;
	КонецЕсли;
	
	Если ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.ДополнительныеОтчетыИОбработки") Тогда
		МодульДополнительныеОтчетыИОбработки = ОбщегоНазначения.ОбщийМодуль("ДополнительныеОтчетыИОбработки");
		МодульДополнительныеОтчетыИОбработки.ПриОпределенииОтчетовСНастройками(Параметры.ОтчетыСНастройками);
	КонецЕсли;
	
	Возврат Параметры;
	
КонецФункции

#КонецОбласти
