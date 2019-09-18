﻿///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2019, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область ПрограммныйИнтерфейс

#Область ДляВызоваИзДругихПодсистем

// СтандартныеПодсистемы.Взаимодействия

// Вызывается при заполнении документа на основании.
//
// Параметры:
//  Контакты  - Массив - массив, содержащий участников взаимодействия.
//
Процедура ЗаполнитьКонтакты(Контакты) Экспорт
	
	Если Не Взаимодействия.КонтактыЗаполнены(Контакты) Тогда
		Возврат;
	КонецЕсли;
	
	Для Каждого СтрокаТаблицы Из Контакты Цикл
		
		Адрес = Неопределено;
		
		Если ТипЗнч(СтрокаТаблицы) = Тип("Структура") Тогда
			// В документ попадут только те контакты, для которых заданы адреса электронной почты.
			МассивАдресов = СтрРазделить(СтрокаТаблицы.Адрес, ",");
			Для каждого ЭлементМассиваАдресов Из МассивАдресов Цикл
				Попытка
					Результат = ОбщегоНазначенияКлиентСервер.РазобратьСтрокуСПочтовымиАдресами(ЭлементМассиваАдресов);
				Исключение
					// Введенная строка с e-mail адресами введена неправильно.
					Продолжить;
				КонецПопытки;
				Если Результат.Количество() > 0 И НЕ ПустаяСтрока(Результат[0]) Тогда
					Адрес = Результат[0];
				КонецЕсли;
				Если Адрес <> Неопределено Тогда
					Прервать;
				КонецЕсли;
			КонецЦикла;
			
			Если Адрес = Неопределено И ЗначениеЗаполнено(СтрокаТаблицы.Контакт) Тогда
				МассивАдресовЭП = ВзаимодействияВызовСервера.ПолучитьАдресаЭлектроннойПочтыКонтакта(СтрокаТаблицы.Контакт);
				Если МассивАдресовЭП.Количество() > 0 Тогда
					Адрес = Новый Структура("Адрес",МассивАдресовЭП[0].АдресЭП);
				КонецЕсли;
			КонецЕсли;
			
			Если НЕ Адрес = Неопределено Тогда
				
				НоваяСтрока = ПолучателиПисьма.Добавить();
				
				НоваяСтрока.Контакт = СтрокаТаблицы.Контакт;
				НоваяСтрока.Представление = СтрокаТаблицы.Представление;
				НоваяСтрока.Адрес = Адрес.Адрес;
			Иначе
				Продолжить;
			КонецЕсли;
			
		Иначе
			НоваяСтрока = ПолучателиПисьма.Добавить();
			НоваяСтрока.Контакт = СтрокаТаблицы;
		КонецЕсли;
		
		Взаимодействия.ДозаполнитьПоляКонтактов(НоваяСтрока.Контакт, НоваяСтрока.Представление,
			НоваяСтрока.Адрес, Перечисления.ТипыКонтактнойИнформации.АдресЭлектроннойПочты);
			
	КонецЦикла;
	
	СформироватьПредставленияКонтактов();
	
КонецПроцедуры

// Конец СтандартныеПодсистемы.Взаимодействия

// СтандартныеПодсистемы.УправлениеДоступом

// См. УправлениеДоступом.ЗаполнитьНаборыЗначенийДоступа.
Процедура ЗаполнитьНаборыЗначенийДоступа(Таблица) Экспорт
	
	ВзаимодействияСобытия.ЗаполнитьНаборыЗначенийДоступа(ЭтотОбъект, Таблица);
	
КонецПроцедуры

// Конец СтандартныеПодсистемы.УправлениеДоступом

#КонецОбласти

#КонецОбласти

#Область ОбработчикиСобытий

Процедура ПередЗаписью(Отказ, РежимЗаписи, РежимПроведения)
	
	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;
	
	ОбновлениеИнформационнойБазы.ПроверитьОбъектОбработан(ЭтотОбъект);
	
	ПредыдущаяПометкаУдаления = Ложь;
	Если Не ЭтоНовый() Тогда
		ПредыдущаяПометкаУдаления = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Ссылка, "ПометкаУдаления");
	КонецЕсли;
	ДополнительныеСвойства.Вставить("ПометкаУдаления", ПредыдущаяПометкаУдаления);
	
	Если ПометкаУдаления <> ПредыдущаяПометкаУдаления Тогда
		ЕстьВложения = ?(ПометкаУдаления, Ложь, РаботаСФайламиСлужебныйВызовСервера.КоличествоПрисоединенныхФайлов(Ссылка) > 0);
	КонецЕсли;
	
КонецПроцедуры

Процедура ПриЗаписи(Отказ)
	
	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;
	
	Взаимодействия.ПриЗаписиДокумента(ЭтотОбъект);
	Взаимодействия.ОтработатьПризнакИзмененияПометкиУдаленияПриЗаписиПисьма(ЭтотОбъект);
	
КонецПроцедуры

Процедура ПередУдалением(Отказ)
	
	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;
	
	УправлениеЭлектроннойПочтой.УдалитьВложенияУПисьма(Ссылка);
	
КонецПроцедуры

Процедура ОбработкаЗаполнения(ДанныеЗаполнения, ТекстЗаполнения, СтандартнаяОбработка)
	
	Если ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.ШаблоныСообщений") Тогда
		МодульШаблоныСообщений = ОбщегоНазначения.ОбщийМодуль("ШаблоныСообщений");
		ЭтоШаблон = МодульШаблоныСообщений.ЭтоШаблон(ДанныеЗаполнения);
	Иначе
		ЭтоШаблон = Ложь;
	КонецЕсли;
		
	Если ЭтоШаблон Тогда
		
		ЗаполнитьНаОснованииШаблона(ДанныеЗаполнения);
		
	ИначеЕсли (ТипЗнч(ДанныеЗаполнения) = Тип("Структура")) И (ДанныеЗаполнения.Свойство("Основание")) 
		 И (ТипЗнч(ДанныеЗаполнения.Основание) = Тип("ДокументСсылка.ЭлектронноеПисьмоВходящее") 
		 ИЛИ ТипЗнч(ДанныеЗаполнения.Основание) = Тип("ДокументСсылка.ЭлектронноеПисьмоИсходящее")) Тогда
		
		Взаимодействия.ЗаполнитьРеквизитыПоУмолчанию(ЭтотОбъект, Неопределено);
		ЗаполнитьНаОснованииПисьма(ДанныеЗаполнения.Основание, ДанныеЗаполнения.Команда);
		
	Иначе
		Взаимодействия.ЗаполнитьРеквизитыПоУмолчанию(ЭтотОбъект, ДанныеЗаполнения);
		
	КонецЕсли;
	
	Важность = Перечисления.ВариантыВажностиВзаимодействия.Обычная;
	СтатусПисьма = Перечисления.СтатусыИсходящегоЭлектронногоПисьма.Черновик;
	Если ПустаяСтрока(Кодировка) Тогда
		Кодировка = "utf-8";
	КонецЕсли;
	
	Если Не ЗначениеЗаполнено(УчетнаяЗапись) Тогда
		УчетнаяЗапись = УправлениеЭлектроннойПочтой.ПолучитьУчетнуюЗаписьДляОтправкиПоУмолчанию();
	КонецЕсли;
	ОтправительПредставление = ПолучитьПредставлениеДляУчетнойЗаписи(УчетнаяЗапись);
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Процедура СформироватьПредставленияКонтактов()
	
	СписокПолучателейПисьма =
		ВзаимодействияКлиентСервер.ПолучитьПредставлениеСпискаАдресатов(ПолучателиПисьма, Ложь);
	СписокПолучателейКопий =
		ВзаимодействияКлиентСервер.ПолучитьПредставлениеСпискаАдресатов(ПолучателиКопий, Ложь);
	СписокПолучателейСкрытыхКопий =
		ВзаимодействияКлиентСервер.ПолучитьПредставлениеСпискаАдресатов(ПолучателиСкрытыхКопий, Ложь);
	
КонецПроцедуры

Процедура ЗаполнитьНаОснованииПисьма(Основание, ТипОтвета)
	
	ПереноситьОтправителя = Истина;
	ПереноситьВсехПолучателей = Ложь;
	ПереноситьВложения = Ложь;
	ДобавлятьКТеме = "RE: ";
	
	Если ТипОтвета = "ОтветитьВсем" Тогда
		ПереноситьВсехПолучателей = Истина;
	ИначеЕсли ТипОтвета = "Переслать" Тогда
		ДобавлятьКТеме = "FW: ";
		ПереноситьОтправителя = Ложь;
		ПереноситьВложения = Истина;
	ИначеЕсли ТипОтвета = "ПереслатьКакВложение" Тогда
		ДобавлятьКТеме = "";
		ПереноситьОтправителя = Ложь;
	КонецЕсли;
	
	ЗаполнитьПараметрыИзПисьма(Основание, ПереноситьОтправителя, ПереноситьВсехПолучателей,
		ДобавлятьКТеме, ПереноситьВложения,ТипОтвета);
	
КонецПроцедуры

Процедура ЗаполнитьНаОснованииШаблона(ШаблонСсылка)
	
	МодульШаблоныСообщений = ОбщегоНазначения.ОбщийМодуль("ШаблоныСообщений");
	Сообщение = МодульШаблоныСообщений.СформироватьСообщение(ШаблонСсылка, Неопределено, Новый УникальныйИдентификатор);
	
	Если ТипЗнч(Сообщение.Текст) = Тип("Структура") Тогда
		
		РезультатТекст = Сообщение.Текст.ТекстHTML;
		СтруктураВложений = Сообщение.Текст.СтруктураВложений;
		ПисьмоHTML             = Истина;
		
	Иначе
		
		СтруктураВложений = Новый Структура();
		РезультатТекст = Сообщение.Текст;
		ПисьмоHTML = СтрНачинаетсяС(РезультатТекст, "<!DOCTYPE html") ИЛИ СтрНачинаетсяС(РезультатТекст, "<html");
		
	КонецЕсли;
	
	Если ТипЗнч(Сообщение.Вложения) <> Неопределено Тогда
		Для каждого Вложение Из Сообщение.Вложения Цикл
			
			Если ЗначениеЗаполнено(Вложение.Идентификатор) Тогда
				Изображение = Новый Картинка(ПолучитьИзВременногоХранилища(Вложение.АдресВоВременномХранилище));
				СтруктураВложений.Вставить(Вложение.Представление, Изображение);
				РезультатТекст = СтрЗаменить(РезультатТекст, "cid:" + Вложение.Идентификатор, Вложение.Представление);
			КонецЕсли;
		КонецЦикла;
		
	КонецЕсли;
	
	Если ПисьмоHTML Тогда
		Если СтруктураВложений.Количество() > 0 Тогда
			ТелоПисьма = Новый Структура();
			ТелоПисьма.Вставить("ТекстHTML",         РезультатТекст);
			ТелоПисьма.Вставить("СтруктураВложений", СтруктураВложений);
			ТекстHTML = ПоместитьВоВременноеХранилище(ТелоПисьма);
		Иначе
			ТекстHTML = РезультатТекст;
		КонецЕсли;
		ТипТекста = Перечисления.ТипыТекстовЭлектронныхПисем.HTML;
	Иначе
		Текст     = РезультатТекст;
		ТипТекста = Перечисления.ТипыТекстовЭлектронныхПисем.ПростойТекст;
	КонецЕсли;
	Тема = Сообщение.Тема;
	
КонецПроцедуры

Функция ПолучитьПредставлениеДляУчетнойЗаписи(УчетнаяЗапись)

	Если Не ЗначениеЗаполнено(УчетнаяЗапись) Тогда
		Возврат "";
	КонецЕсли;

	Запрос = Новый Запрос;
	Запрос.Текст =
	"ВЫБРАТЬ
	|	УчетныеЗаписиЭлектроннойПочты.ИмяПользователя,
	|	УчетныеЗаписиЭлектроннойПочты.АдресЭлектроннойПочты
	|ИЗ
	|	Справочник.УчетныеЗаписиЭлектроннойПочты КАК УчетныеЗаписиЭлектроннойПочты
	|ГДЕ
	|	УчетныеЗаписиЭлектроннойПочты.Ссылка = &УчетнаяЗапись";
	Запрос.УстановитьПараметр("УчетнаяЗапись", УчетнаяЗапись);
	Выборка = Запрос.Выполнить().Выбрать();
	Выборка.Следующий();
	
	Представление = Выборка.ИмяПользователя;
	Если ПустаяСтрока(Представление) Тогда
		Возврат Выборка.АдресЭлектроннойПочты;
	Иначе
		Возврат Представление + " <" + Выборка.АдресЭлектроннойПочты + ">";
	КонецЕсли;

КонецФункции

Процедура ДобавитьПолучателя(Адрес, Представление, Контакт)
	
	НоваяСтрока = ПолучателиПисьма.Добавить();
	НоваяСтрока.Адрес = Адрес;
	НоваяСтрока.Контакт = Контакт;
	НоваяСтрока.Представление = Представление;
	
КонецПроцедуры

Процедура ДобавитьПолучателейИзТаблицы(Таблица)
	
	Для Каждого СтрокаТаблицы Из Таблица Цикл
		НоваяСтрока = ПолучателиПисьма.Добавить();
		ЗаполнитьЗначенияСвойств(НоваяСтрока, СтрокаТаблицы);
	КонецЦикла;
	
КонецПроцедуры

Процедура ЗаполнитьПараметрыИзПисьма(Письмо, ПереноситьОтправителяВПолучатели, 
	
	ПереноситьВсехПолучателейПисьмаВПолучатели, ДобавлятьКТеме, ПереноситьВложения, ТипОтвета)
	
	ИмяОбъектаМетаданных = Письмо.Метаданные().Имя;
	
	Запрос = Новый Запрос;
	Запрос.Текст ="ВЫБРАТЬ
	|	ЭлектронноеПисьмо.ИдентификаторСообщения,
	|	ЭлектронноеПисьмо.ИдентификаторыОснований,
	|	ЭлектронноеПисьмо.Кодировка,
	|	ЕСТЬNULL(ПредметыПапкиВзаимодействий.Предмет, НЕОПРЕДЕЛЕНО) КАК Предмет,
	|	ЭлектронноеПисьмо.Тема,
	|	ЭлектронноеПисьмо.УчетнаяЗапись,
	|	ЭлектронноеПисьмо.ТипТекста,
	|	ЭлектронноеПисьмо.Ссылка" +?(ПереноситьОтправителяВПолучатели,",
	|	ЭлектронноеПисьмо.ОтправительАдрес,
	|	ЭлектронноеПисьмо.ОтправительКонтакт,
	|	ЭлектронноеПисьмо.ОтправительПредставление", "") + "
	|ИЗ
	|	Документ." + ИмяОбъектаМетаданных + " КАК ЭлектронноеПисьмо
	|	ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.ПредметыПапкиВзаимодействий КАК ПредметыПапкиВзаимодействий
	|		ПО ЭлектронноеПисьмо.Ссылка =  ПредметыПапкиВзаимодействий.Взаимодействие
	|ГДЕ
	|	ЭлектронноеПисьмо.Ссылка = &Ссылка";
	
	Запрос.УстановитьПараметр("Ссылка", Письмо);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	Если РезультатЗапроса.Пустой() Тогда
		Возврат;
	КонецЕсли;
	
	Выборка = РезультатЗапроса.Выбрать();
	Выборка.Следующий();
	
	ИдентификаторОснования       = Выборка.ИдентификаторСообщения;
	ИдентификаторыОснований      = СокрЛП(Выборка.ИдентификаторыОснований + " <" + ИдентификаторОснования + ">");
	Кодировка                    = Выборка.Кодировка;
	Предмет                      = Выборка.Предмет;
	Тема                         = ДобавлятьКТеме + Выборка.Тема;
	УчетнаяЗапись                = Выборка.УчетнаяЗапись;
	ВзаимодействиеОснование      = Выборка.Ссылка;
	ВключатьТелоИсходногоПисьма  = Истина;
	ТипТекста                    = Выборка.ТипТекста;
	
	Если ПереноситьОтправителяВПолучатели Тогда
		ДобавитьПолучателя(Выборка.ОтправительАдрес, Выборка.ОтправительПредставление, Выборка.ОтправительКонтакт);
	КонецЕсли;
	
	Если ПереноситьВсехПолучателейПисьмаВПолучатели Тогда
		
		Запрос.Текст = "ВЫБРАТЬ РАЗРЕШЕННЫЕ
		|	УчетныеЗаписиЭлектроннойПочты.АдресЭлектроннойПочты
		|ПОМЕСТИТЬ АдресТекущегоПолучателя
		|ИЗ
		|	Справочник.УчетныеЗаписиЭлектроннойПочты КАК УчетныеЗаписиЭлектроннойПочты
		|ГДЕ
		|	УчетныеЗаписиЭлектроннойПочты.Ссылка В
		|			(ВЫБРАТЬ
		|				ЭлектронноеПисьмо.УчетнаяЗапись
		|			ИЗ
		|				Документ." + ИмяОбъектаМетаданных + " КАК ЭлектронноеПисьмо
		|			ГДЕ
		|				ЭлектронноеПисьмо.Ссылка = &Ссылка)
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	ЭлектронноеПисьмоПолучателиПисьма.Адрес,
		|	ЭлектронноеПисьмоПолучателиПисьма.Представление,
		|	ЭлектронноеПисьмоПолучателиПисьма.Контакт
		|ИЗ
		|	Документ." + ИмяОбъектаМетаданных + ".ПолучателиПисьма КАК ЭлектронноеПисьмоПолучателиПисьма
		|ГДЕ
		|	ЭлектронноеПисьмоПолучателиПисьма.Ссылка = &Ссылка
		|	И (НЕ ЭлектронноеПисьмоПолучателиПисьма.Адрес В
		|				(ВЫБРАТЬ
		|					АдресТекущегоПолучателя.АдресЭлектроннойПочты
		|				ИЗ
		|					АдресТекущегоПолучателя КАК АдресТекущегоПолучателя))
		|
		|ОБЪЕДИНИТЬ ВСЕ
		|
		|ВЫБРАТЬ
		|	ЭлектронноеПисьмоПолучателиКопий.Адрес,
		|	ЭлектронноеПисьмоПолучателиКопий.Представление,
		|	ЭлектронноеПисьмоПолучателиКопий.Контакт
		|ИЗ
		|	Документ." + ИмяОбъектаМетаданных + ".ПолучателиКопий КАК ЭлектронноеПисьмоПолучателиКопий
		|ГДЕ
		|	ЭлектронноеПисьмоПолучателиКопий.Ссылка = &Ссылка
		|	И (НЕ ЭлектронноеПисьмоПолучателиКопий.Адрес В
		|				(ВЫБРАТЬ
		|					АдресТекущегоПолучателя.АдресЭлектроннойПочты
		|				ИЗ
		|					АдресТекущегоПолучателя КАК АдресТекущегоПолучателя))";
		
		Запрос.УстановитьПараметр("АдресОтправителяЭтогоПисьма",Письмо.УчетнаяЗапись.АдресЭлектроннойПочты);
		
		РезультатЗапроса = Запрос.Выполнить();
		
		Если НЕ РезультатЗапроса.Пустой() Тогда
			ДобавитьПолучателейИзТаблицы(РезультатЗапроса.Выгрузить());
		КонецЕсли;
		
	КонецЕсли;
	
	СписокПолучателейПисьма = ВзаимодействияКлиентСервер.ПолучитьПредставлениеСпискаАдресатов(ПолучателиПисьма, Ложь);
	
КонецПроцедуры

#КонецОбласти

#Иначе
ВызватьИсключение НСтр("ru = 'Недопустимый вызов объекта на клиенте.'");
#КонецЕсли