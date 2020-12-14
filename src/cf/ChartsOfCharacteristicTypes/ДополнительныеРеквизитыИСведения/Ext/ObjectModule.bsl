﻿///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2020, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область ОбработчикиСобытий

Процедура ПриКопировании(ОбъектКопирования)
	
	Заголовок = "";
	Имя       = "";
	ИдентификаторДляФормул = "";
	
КонецПроцедуры

Процедура ПередЗаписью(Отказ)
	
	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;
	
	КонтрольЗаполнениеИдентификатораДляФормул(Отказ);
	
	ОбновлениеИнформационнойБазы.ПроверитьОбъектОбработан(ЭтотОбъект);
	
КонецПроцедуры

Процедура ПриЗаписи(Отказ)
	
	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;
	
	Если УправлениеСвойствамиСлужебный.ТипЗначенияСодержитЗначенияСвойств(ТипЗначения) Тогда
		
		Запрос = Новый Запрос;
		Запрос.УстановитьПараметр("ВладелецЗначений", Ссылка);
		Запрос.Текст =
		"ВЫБРАТЬ
		|	Свойства.Ссылка КАК Ссылка,
		|	Свойства.ТипЗначения КАК ТипЗначения
		|ИЗ
		|	ПланВидовХарактеристик.ДополнительныеРеквизитыИСведения КАК Свойства
		|ГДЕ
		|	Свойства.ВладелецДополнительныхЗначений = &ВладелецЗначений";
		Выборка = Запрос.Выполнить().Выбрать();
		
		Пока Выборка.Следующий() Цикл
			НовыйТипЗначения = Неопределено;
			
			Если ТипЗначения.СодержитТип(Тип("СправочникСсылка.ЗначенияСвойствОбъектов"))
			   И НЕ Выборка.ТипЗначения.СодержитТип(Тип("СправочникСсылка.ЗначенияСвойствОбъектов")) Тогда
				
				НовыйТипЗначения = Новый ОписаниеТипов(
					Выборка.ТипЗначения,
					"СправочникСсылка.ЗначенияСвойствОбъектов",
					"СправочникСсылка.ЗначенияСвойствОбъектовИерархия");
				
			ИначеЕсли ТипЗначения.СодержитТип(Тип("СправочникСсылка.ЗначенияСвойствОбъектовИерархия"))
			        И НЕ Выборка.ТипЗначения.СодержитТип(Тип("СправочникСсылка.ЗначенияСвойствОбъектовИерархия")) Тогда
				
				НовыйТипЗначения = Новый ОписаниеТипов(
					Выборка.ТипЗначения,
					"СправочникСсылка.ЗначенияСвойствОбъектовИерархия",
					"СправочникСсылка.ЗначенияСвойствОбъектов");
				
			КонецЕсли;
			
			Если НовыйТипЗначения <> Неопределено Тогда
				Блокировка = Новый БлокировкаДанных;
				ЭлементБлокировки = Блокировка.Добавить("ПланВидовХарактеристик.ДополнительныеРеквизитыИСведения");
				ЭлементБлокировки.УстановитьЗначение("Ссылка", Выборка.Ссылка);
				Блокировка.Заблокировать();
				
				ТекущийОбъект = Выборка.Ссылка.ПолучитьОбъект();
				ТекущийОбъект.ТипЗначения = НовыйТипЗначения;
				ТекущийОбъект.ОбменДанными.Загрузка = Истина;
				ТекущийОбъект.Записать();
			КонецЕсли;
		КонецЦикла;
	КонецЕсли;
	
	// Проверка, что изменение пометки удаления произведено не из списка.
	// Наборы дополнительных реквизитов и сведений.
	СвойстваОбъекта = ОбщегоНазначения.ЗначенияРеквизитовОбъекта(Ссылка, "ПометкаУдаления");
	Запрос = Новый Запрос;
	Запрос.Текст =
		"ВЫБРАТЬ
		|	Наборы.Ссылка КАК Ссылка
		|ИЗ
		|	&ИмяТаблицы КАК Свойства
		|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.НаборыДополнительныхРеквизитовИСведений КАК Наборы
		|		ПО (Свойства.Ссылка = Наборы.Ссылка)
		|ГДЕ
		|	Свойства.Свойство = &Свойство
		|	И Свойства.ПометкаУдаления <> &ПометкаУдаления";
	Если ЭтоДополнительноеСведение Тогда
		ИмяТаблицы = "Справочник.НаборыДополнительныхРеквизитовИСведений.ДополнительныеСведения";
	Иначе
		ИмяТаблицы = "Справочник.НаборыДополнительныхРеквизитовИСведений.ДополнительныеРеквизиты";
	КонецЕсли;
	Запрос.Текст = СтрЗаменить(Запрос.Текст, "&ИмяТаблицы", ИмяТаблицы);
	Запрос.УстановитьПараметр("Свойство", Ссылка);
	Запрос.УстановитьПараметр("ПометкаУдаления", СвойстваОбъекта.ПометкаУдаления);
	
	Результат = Запрос.Выполнить().Выгрузить();
	
	Для Каждого СтрокаРезультата Из Результат Цикл
		НаборСвойствОбъект = СтрокаРезультата.Ссылка.ПолучитьОбъект();// СправочникОбъект.НаборыДополнительныхРеквизитовИСведений,
		Если ЭтоДополнительноеСведение Тогда
			ЗаполнитьЗначенияСвойств(НаборСвойствОбъект.ДополнительныеСведения.Найти(Ссылка, "Свойство"), СвойстваОбъекта);
		Иначе
			ЗаполнитьЗначенияСвойств(НаборСвойствОбъект.ДополнительныеРеквизиты.Найти(Ссылка, "Свойство"), СвойстваОбъекта);
		КонецЕсли;
		
		НаборСвойствОбъект.Записать();
	КонецЦикла;
	
КонецПроцедуры

Процедура ПередУдалением(Отказ)
	
	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("Свойство", Ссылка);
	Запрос.Текст =
	"ВЫБРАТЬ
	|	НаборыСвойств.Ссылка КАК Ссылка
	|ИЗ
	|	Справочник.НаборыДополнительныхРеквизитовИСведений.ДополнительныеРеквизиты КАК НаборыСвойств
	|ГДЕ
	|	НаборыСвойств.Свойство = &Свойство
	|
	|ОБЪЕДИНИТЬ ВСЕ
	|
	|ВЫБРАТЬ
	|	НаборыСвойств.Ссылка
	|ИЗ
	|	Справочник.НаборыДополнительныхРеквизитовИСведений.ДополнительныеСведения КАК НаборыСвойств
	|ГДЕ
	|	НаборыСвойств.Свойство = &Свойство";
	
	Выборка = Запрос.Выполнить().Выбрать();
	
	Пока Выборка.Следующий() Цикл
		Блокировка = Новый БлокировкаДанных;
		ЭлементБлокировки = Блокировка.Добавить("Справочник.НаборыДополнительныхРеквизитовИСведений");
		ЭлементБлокировки.УстановитьЗначение("Ссылка", Выборка.Ссылка);
		Блокировка.Заблокировать();
		
		ТекущийОбъект = Выборка.Ссылка.ПолучитьОбъект();
		// Удаление дополнительных реквизитов.
		Индекс = ТекущийОбъект.ДополнительныеРеквизиты.Количество()-1;
		Пока Индекс >= 0 Цикл
			Если ТекущийОбъект.ДополнительныеРеквизиты[Индекс].Свойство = Ссылка Тогда
				ТекущийОбъект.ДополнительныеРеквизиты.Удалить(Индекс);
			КонецЕсли;
			Индекс = Индекс - 1;
		КонецЦикла;
		// Удаление дополнительных сведений.
		Индекс = ТекущийОбъект.ДополнительныеСведения.Количество()-1;
		Пока Индекс >= 0 Цикл
			Если ТекущийОбъект.ДополнительныеСведения[Индекс].Свойство = Ссылка Тогда
				ТекущийОбъект.ДополнительныеСведения.Удалить(Индекс);
			КонецЕсли;
			Индекс = Индекс - 1;
		КонецЦикла;
		Если ТекущийОбъект.Модифицированность() Тогда
			ТекущийОбъект.ОбменДанными.Загрузка = Истина;
			ТекущийОбъект.Записать();
		КонецЕсли;
	КонецЦикла;
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныйПрограммныйИнтерфейс

Процедура ПриЧтенииПредставленийНаСервере() Экспорт
	
	Если ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.Мультиязычность") Тогда
		МодульМультиязычностьСервер = ОбщегоНазначения.ОбщийМодуль("МультиязычностьСервер");
		МодульМультиязычностьСервер.ПриЧтенииПредставленийНаСервере(ЭтотОбъект);
	КонецЕсли;
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Процедура КонтрольЗаполнениеИдентификатораДляФормул(Отказ)
	Если НЕ ДополнительныеСвойства.Свойство("ПроверкаИдентификатораДляФормулВыполнена") Тогда
		// Программная запись.
		Если ЗначениеЗаполнено(ИдентификаторДляФормул) Тогда
			ПланыВидовХарактеристик.ДополнительныеРеквизитыИСведения.ПроверитьУникальностьИдентификатора(ИдентификаторДляФормул, Ссылка, Отказ);
		Иначе
			// Установка идентификатора.
			ИдентификаторДляФормул = ПланыВидовХарактеристик.ДополнительныеРеквизитыИСведения.УникальныйИдентификаторДляФормул(
				ЗаголовокДляФормированияИдентификатора(), Ссылка);
		КонецЕсли;
	КонецЕсли;
КонецПроцедуры

Функция ЗаголовокДляФормированияИдентификатора()
	ЗаголовокДляИдентификатора = Заголовок;
	Если ТекущийЯзык() <> ОбщегоНазначения.КодОсновногоЯзыка() Тогда
		Отбор = Новый Структура();
		Отбор.Вставить("КодЯзыка", ОбщегоНазначения.КодОсновногоЯзыка());
		НайденныеСтроки = Представления.НайтиСтроки(Отбор);
		Если НайденныеСтроки.Количество() > 0 Тогда
			ЗаголовокДляИдентификатора = НайденныеСтроки[0].Заголовок;
		КонецЕсли;
	КонецЕсли;
	
	Возврат ЗаголовокДляИдентификатора;
КонецФункции

#КонецОбласти

#Иначе
ВызватьИсключение НСтр("ru = 'Недопустимый вызов объекта на клиенте.'");
#КонецЕсли