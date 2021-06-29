﻿///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2021, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Если Параметры.Идентификатор <> Неопределено Тогда
		ОписаниеИнтеграции = Вычислить("СистемаВзаимодействия.ПолучитьИнтеграцию(Параметры.Идентификатор)"); // АПК:488-безопасный код
		Если ОписаниеИнтеграции <> Неопределено Тогда
			Наименование = ОписаниеИнтеграции.Представление;
			Токен = ОписаниеИнтеграции.ПараметрыВнешнейСистемы.Получить("token");
			ИдГруппы = ОписаниеИнтеграции.ПараметрыВнешнейСистемы.Получить("groupId");
			
			Участники.Очистить();
			Для каждого ПользовательИБ Из Обсуждения.ПользователиИнформационнойБазы(ОписаниеИнтеграции.Участники) Цикл
				Участники.Добавить().Пользователь = ПользовательИБ.Значение;
			КонецЦикла;
		КонецЕсли;
		
		Если ОписаниеИнтеграции.Использование Тогда
			Элементы.Закрыть.Заголовок = НСтр("ru='Изменить'");
			Элементы.Отключить.Видимость = Истина;
		КонецЕсли;
		
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура ОбработкаПроверкиЗаполненияНаСервере(Отказ, ПроверяемыеРеквизиты)
	Если НЕ СтроковыеФункцииКлиентСервер.ТолькоЦифрыВСтроке(ИдГруппы) Тогда
		ОбщегоНазначения.СообщитьПользователю(НСтр("ru='Ключ группы должен содержать только цифры.'")
			,,"ИдГруппы",,Отказ);
	КонецЕсли;
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура Подобрать(Команда)
	ОбсужденияСлужебныйКлиент.НачатьПодборУчастниковОбсуждения(Элементы.Участники);
КонецПроцедуры

&НаКлиенте
Процедура АктивироватьБота(Команда)
	Если НЕ ПроверитьЗаполнение() Тогда
		Возврат;
	КонецЕсли;
	
	Попытка
		АктивироватьСервер();
		Закрыть(Истина);
	Исключение
		ПоказатьПредупреждение(, НСтр("ru='Во время активизации чат-бота произошла ошибка'")
			+ Символы.ПС + КраткоеПредставлениеОшибки(ИнформацияОбОшибке()));
	КонецПопытки;
КонецПроцедуры

&НаСервере
Процедура АктивироватьСервер()
	
	ПараметрыИнтеграции = Новый Структура;
	ПараметрыИнтеграции.Вставить("Идентификатор", Параметры.Идентификатор);
	ПараметрыИнтеграции.Вставить("Ключ", Наименование); 
	ПараметрыИнтеграции.Вставить("Тип", ОбсужденияСлужебныйКлиентСервер.ТипыВнешнихСистем().ВКонтакте);
	ПараметрыИнтеграции.Вставить("Участники", Участники.Выгрузить(,"Пользователь").ВыгрузитьКолонку("Пользователь"));
	ПараметрыИнтеграции.Вставить("token", Токен);
	ПараметрыИнтеграции.Вставить("groupId", ИдГруппы);
	
	Попытка
		ОбсужденияСлужебный.СоздатьИзменитьИнтеграцию(ПараметрыИнтеграции);
	Исключение
		ЗаписьЖурналаРегистрации(ОбсужденияСлужебный.СобытиеЖурналаРегистрации(),
			УровеньЖурналаРегистрации.Ошибка,,,
			ПодробноеПредставлениеОшибки(ИнформацияОбОшибке()));
		ВызватьИсключение;
	КонецПопытки;

КонецПроцедуры

&НаКлиенте
Процедура УчастникиОбработкаВыбора(Элемент, ВыбранноеЗначение, СтандартнаяОбработка)
	СтандартнаяОбработка = Ложь;
	Если ВыбранноеЗначение = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	Для каждого ПодобранныйПользователь Из ВыбранноеЗначение Цикл
		Если Участники.НайтиСтроки(Новый Структура("Пользователь", ПодобранныйПользователь)).Количество() = 0 Тогда
			Участники.Добавить().Пользователь = ПодобранныйПользователь;
		КонецЕсли;
	КонецЦикла;
КонецПроцедуры

&НаКлиенте
Процедура Отключить(Команда)
	Попытка
		ОтключитьСервер();
	    Закрыть(Истина);
	Исключение
		ПоказатьПредупреждение(, НСтр("ru='Во время отключение чат-бота произошла ошибка'")
			+ Символы.ПС + КраткоеПредставлениеОшибки(ИнформацияОбОшибке()));
	КонецПопытки;
КонецПроцедуры

&НаСервере
Процедура ОтключитьСервер()
	ОбсужденияСлужебный.ОтключитьИнтеграцию(Параметры.Идентификатор);
КонецПроцедуры

#КонецОбласти

