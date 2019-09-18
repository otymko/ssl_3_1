﻿///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2019, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область СлужебныеПроцедурыИФункции

Функция ТекущиеНастройкиОчистки() Экспорт
	
	УстановитьПривилегированныйРежим(Истина);
	
	ОбновитьНастройкиОчистки();
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	НастройкиОчисткиФайлов.ВладелецФайла,
		|	ИдентификаторыОбъектовМетаданных.Ссылка КАК ИдентификаторВладельца,
		|	ВЫБОР
		|		КОГДА ТИПЗНАЧЕНИЯ(ИдентификаторыОбъектовМетаданных.Ссылка) <> ТИПЗНАЧЕНИЯ(НастройкиОчисткиФайлов.ВладелецФайла)
		|			ТОГДА ИСТИНА
		|		ИНАЧЕ ЛОЖЬ
		|	КОНЕЦ КАК ЭтоНастройкаДляЭлементаСправочника,
		|	НастройкиОчисткиФайлов.ТипВладельцаФайла,
		|	НастройкиОчисткиФайлов.ПравилоОтбора,
		|	НастройкиОчисткиФайлов.Действие,
		|	НастройкиОчисткиФайлов.ПериодОчистки,
		|	НастройкиОчисткиФайлов.ЭтоФайл
		|ИЗ
		|	РегистрСведений.НастройкиОчисткиФайлов КАК НастройкиОчисткиФайлов
		|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.ИдентификаторыОбъектовМетаданных КАК ИдентификаторыОбъектовМетаданных
		|		ПО (ТИПЗНАЧЕНИЯ(НастройкиОчисткиФайлов.ВладелецФайла) = ТИПЗНАЧЕНИЯ(ИдентификаторыОбъектовМетаданных.ЗначениеПустойСсылки))";
		
	Возврат Запрос.Выполнить().Выгрузить();
	
КонецФункции

Процедура ОбновитьНастройкиОчистки()
	
	МетаданныеСправочники = Метаданные.Справочники;
	
	ТаблицаВладельцевФайлов = Новый ТаблицаЗначений;
	ТаблицаВладельцевФайлов.Колонки.Добавить("ВладелецФайла",     Новый ОписаниеТипов("СправочникСсылка.ИдентификаторыОбъектовМетаданных"));
	ТаблицаВладельцевФайлов.Колонки.Добавить("ТипВладельцаФайла", Новый ОписаниеТипов("СправочникСсылка.ИдентификаторыОбъектовМетаданных"));
	ТаблицаВладельцевФайлов.Колонки.Добавить("ЭтоФайл",           Новый ОписаниеТипов("Булево"));
	
	МассивИсключений = РаботаСФайламиСлужебный.ОбъектыИсключенияПриОчисткеФайлов();
	Для Каждого Справочник Из МетаданныеСправочники Цикл
		
		Если Справочник.Реквизиты.Найти("ВладелецФайла") = Неопределено Тогда
			Продолжить;
		КонецЕсли;
		
		ТипыВладельцевФайлов = Справочник.Реквизиты.ВладелецФайла.Тип.Типы();
		Для Каждого ТипВладельца Из ТипыВладельцевФайлов Цикл
			
			МетаданныеВладельца = Метаданные.НайтиПоТипу(ТипВладельца);
			Если МассивИсключений.Найти(МетаданныеВладельца) <> Неопределено Тогда
				Продолжить;
			КонецЕсли;
			
			НоваяСтрока = ТаблицаВладельцевФайлов.Добавить();
			НоваяСтрока.ВладелецФайла = ОбщегоНазначения.ИдентификаторОбъектаМетаданных(ТипВладельца);
			НоваяСтрока.ТипВладельцаФайла = ОбщегоНазначения.ИдентификаторОбъектаМетаданных(Справочник);
			Если Не СтрЗаканчиваетсяНа(Справочник.Имя, "ПрисоединенныеФайлы") Тогда
				НоваяСтрока.ЭтоФайл = Истина;
			КонецЕсли;
			
		КонецЦикла;
		
	КонецЦикла;
	
	Запрос = Новый Запрос;
	Запрос.Текст =
		"ВЫБРАТЬ
		|	ТаблицаВладельцевФайлов.ВладелецФайла КАК ВладелецФайла,
		|	ТаблицаВладельцевФайлов.ТипВладельцаФайла КАК ТипВладельцаФайла,
		|	ТаблицаВладельцевФайлов.ЭтоФайл КАК ЭтоФайл
		|ПОМЕСТИТЬ ТаблицаВладельцевФайлов
		|ИЗ
		|	&ТаблицаВладельцевФайлов КАК ТаблицаВладельцевФайлов
		|
		|ИНДЕКСИРОВАТЬ ПО
		|	ВладелецФайла,
		|	ЭтоФайл
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	НастройкиОчисткиФайлов.ВладелецФайла,
		|	НастройкиОчисткиФайлов.ТипВладельцаФайла КАК ТипВладельцаФайла,
		|	НастройкиОчисткиФайлов.ЭтоФайл КАК ЭтоФайл,
		|	ИдентификаторыОбъектовМетаданных.Ссылка КАК ИдентификаторОбъекта
		|ПОМЕСТИТЬ ПодчиненныеНастройки
		|ИЗ
		|	РегистрСведений.НастройкиОчисткиФайлов КАК НастройкиОчисткиФайлов
		|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.ИдентификаторыОбъектовМетаданных КАК ИдентификаторыОбъектовМетаданных
		|		ПО (ТИПЗНАЧЕНИЯ(НастройкиОчисткиФайлов.ВладелецФайла) = ТИПЗНАЧЕНИЯ(ИдентификаторыОбъектовМетаданных.ЗначениеПустойСсылки))
		|ГДЕ
		|	ТИПЗНАЧЕНИЯ(НастройкиОчисткиФайлов.ВладелецФайла) <> ТИП(Справочник.ИдентификаторыОбъектовМетаданных)
		|
		|ИНДЕКСИРОВАТЬ ПО
		|	ИдентификаторОбъекта,
		|	ЭтоФайл,
		|	ТипВладельцаФайла
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	НастройкиОчисткиФайлов.ВладелецФайла,
		|	НастройкиОчисткиФайлов.ТипВладельцаФайла КАК ТипВладельцаФайла,
		|	НастройкиОчисткиФайлов.ЭтоФайл,
		|	ЛОЖЬ КАК НоваяНастройка
		|ИЗ
		|	РегистрСведений.НастройкиОчисткиФайлов КАК НастройкиОчисткиФайлов
		|		ЛЕВОЕ СОЕДИНЕНИЕ ТаблицаВладельцевФайлов КАК ТаблицаВладельцевФайлов
		|		ПО НастройкиОчисткиФайлов.ВладелецФайла = ТаблицаВладельцевФайлов.ВладелецФайла
		|			И НастройкиОчисткиФайлов.ЭтоФайл = ТаблицаВладельцевФайлов.ЭтоФайл
		|			И НастройкиОчисткиФайлов.ТипВладельцаФайла = ТаблицаВладельцевФайлов.ТипВладельцаФайла
		|ГДЕ
		|	ТаблицаВладельцевФайлов.ВладелецФайла ЕСТЬ NULL 
		|	И ТИПЗНАЧЕНИЯ(НастройкиОчисткиФайлов.ВладелецФайла) = ТИП(Справочник.ИдентификаторыОбъектовМетаданных)
		|
		|ОБЪЕДИНИТЬ ВСЕ
		|
		|ВЫБРАТЬ
		|	ПодчиненныеНастройки.ВладелецФайла,
		|	ПодчиненныеНастройки.ТипВладельцаФайла,
		|	ПодчиненныеНастройки.ЭтоФайл,
		|	ЛОЖЬ
		|ИЗ
		|	ПодчиненныеНастройки КАК ПодчиненныеНастройки
		|		ЛЕВОЕ СОЕДИНЕНИЕ ТаблицаВладельцевФайлов КАК ТаблицаВладельцевФайлов
		|		ПО ПодчиненныеНастройки.ТипВладельцаФайла = ТаблицаВладельцевФайлов.ТипВладельцаФайла
		|			И ПодчиненныеНастройки.ЭтоФайл = ТаблицаВладельцевФайлов.ЭтоФайл
		|			И ПодчиненныеНастройки.ИдентификаторОбъекта = ТаблицаВладельцевФайлов.ВладелецФайла
		|ГДЕ
		|	ТаблицаВладельцевФайлов.ВладелецФайла ЕСТЬ NULL ";
	
	Запрос.Параметры.Вставить("ТаблицаВладельцевФайлов", ТаблицаВладельцевФайлов);
	ОбщаяТаблицаНастроек = Запрос.Выполнить().Выгрузить();
	
	НастройкиДляУдаления = ОбщаяТаблицаНастроек.НайтиСтроки(Новый Структура("НоваяНастройка", Ложь));
	Для Каждого Настройка Из НастройкиДляУдаления Цикл
		МенеджерЗаписи = СоздатьМенеджерЗаписи();
		МенеджерЗаписи.ВладелецФайла = Настройка.ВладелецФайла;
		МенеджерЗаписи.ТипВладельцаФайла = Настройка.ТипВладельцаФайла;
		МенеджерЗаписи.Удалить();
	КонецЦикла;
	
КонецПроцедуры

#КонецОбласти

#КонецЕсли