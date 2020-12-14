﻿///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2020, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область СлужебныйПрограммныйИнтерфейс

////////////////////////////////////////////////////////////////////////////////
// Обслуживание таблиц ВидыДоступа и ЗначенияДоступа в формах редактирования.

////////////////////////////////////////////////////////////////////////////////
// Обработчики событий таблицы формы ЗначенияДоступа.

// Только для внутреннего использования.
// 
// Параметры:
//  Форма - см. УправлениеДоступомСлужебныйКлиентСервер.ПараметрыФормыРедактированияРазрешенныхЗначений
//  Элемент - ТаблицаФормы
//
Процедура ЗначенияДоступаПриИзменении(Форма, Элемент) Экспорт
	
	Элементы = Форма.Элементы;
	Параметры = ПараметрыФормыРедактированияРазрешенныхЗначений(Форма);
	
	Если Элемент.ТекущиеДанные <> Неопределено
	   И Элемент.ТекущиеДанные.ВидДоступа = Неопределено Тогда
		
		Отбор = УправлениеДоступомСлужебныйКлиентСервер.ОтборВТаблицахФормыРедактированияРазрешенныхЗначений(
			Форма, Форма.ТекущийВидДоступа);
		
		ЗаполнитьЗначенияСвойств(Элемент.ТекущиеДанные, Отбор);
		
		Элемент.ТекущиеДанные.НомерСтрокиПоВиду = Параметры.ЗначенияДоступа.НайтиСтроки(Отбор).Количество();
	КонецЕсли;
	
	УправлениеДоступомСлужебныйКлиентСервер.ЗаполнитьНомераСтрокЗначенийДоступаПоВиду(
		Форма, Элементы.ВидыДоступа.ТекущиеДанные);
	
	УправлениеДоступомСлужебныйКлиентСервер.ЗаполнитьВсеРазрешеныПредставление(
		Форма, Элементы.ВидыДоступа.ТекущиеДанные);
	
КонецПроцедуры

// Только для внутреннего использования.
// 
// Параметры:
//  Форма - см. УправлениеДоступомСлужебныйКлиентСервер.ПараметрыФормыРедактированияРазрешенныхЗначений
//  Элемент - ТаблицаФормы
//  НоваяСтрока - Булево
//  Копирование - Булево
//
Процедура ЗначенияДоступаПриНачалеРедактирования(Форма, Элемент, НоваяСтрока, Копирование) Экспорт
	
	Элементы = Форма.Элементы;
	
	Если Элемент.ТекущиеДанные.ЗначениеДоступа = Неопределено Тогда
		Если Форма.ТекущиеТипыВыбираемыхЗначений.Количество() > 1
		   И Форма.ТекущийВидДоступа <> Форма.ВидДоступаВнешниеПользователи
		   И Форма.ТекущийВидДоступа <> Форма.ВидДоступаПользователи Тогда
			
			Элементы.ЗначенияДоступаЗначениеДоступа.КнопкаВыбора = Истина;
		Иначе
			Элементы.ЗначенияДоступаЗначениеДоступа.КнопкаВыбора = Неопределено;
			Элементы.ЗначенияДоступа.ТекущиеДанные.ЗначениеДоступа = Форма.ТекущиеТипыВыбираемыхЗначений[0].Значение;
			Форма.ТекущийТипВыбираемыхЗначений = Форма.ТекущиеТипыВыбираемыхЗначений[0].Значение
		КонецЕсли;
	КонецЕсли;
	
	Элементы.ЗначенияДоступаЗначениеДоступа.КнопкаОчистки
		= Форма.ТекущийТипВыбираемыхЗначений <> Неопределено
		И Форма.ТекущиеТипыВыбираемыхЗначений.Количество() > 1;
	
КонецПроцедуры

// Только для внутреннего использования.
Процедура ЗначениеДоступаНачалоВыбора(Форма, Элемент, ДанныеВыбора, СтандартнаяОбработка) Экспорт
	
	СтандартнаяОбработка = Ложь;
	
	Если Форма.ТекущиеТипыВыбираемыхЗначений.Количество() = 1 Тогда
		
		Форма.ТекущийТипВыбираемыхЗначений = Форма.ТекущиеТипыВыбираемыхЗначений[0].Значение;
		
		ЗначениеДоступаНачалоВыбораЗавершение(Форма);
		Возврат;
		
	ИначеЕсли Форма.ТекущиеТипыВыбираемыхЗначений.Количество() > 0 Тогда
		
		Если Форма.ТекущиеТипыВыбираемыхЗначений.Количество() = 2 Тогда
		
			Если Форма.ТекущийВидДоступа = Форма.ВидДоступаПользователи Тогда
				Форма.ТекущийТипВыбираемыхЗначений = ПредопределенноеЗначение(
					"Справочник.Пользователи.ПустаяСсылка");
				
				ЗначениеДоступаНачалоВыбораЗавершение(Форма);
				Возврат;
			КонецЕсли;
			
			Если Форма.ТекущийВидДоступа = Форма.ВидДоступаВнешниеПользователи Тогда
				Форма.ТекущийТипВыбираемыхЗначений = ПредопределенноеЗначение(
					"Справочник.ВнешниеПользователи.ПустаяСсылка");
				
				ЗначениеДоступаНачалоВыбораЗавершение(Форма);
				Возврат;
			КонецЕсли;
		КонецЕсли;
		
		Форма.ТекущиеТипыВыбираемыхЗначений.ПоказатьВыборЭлемента(
			Новый ОписаниеОповещения("ЗначениеДоступаНачалоВыбораПродолжение", ЭтотОбъект, Форма),
			НСтр("ru = 'Выбор типа данных'"),
			Форма.ТекущиеТипыВыбираемыхЗначений[0]);
	КонецЕсли;
	
КонецПроцедуры

// Только для внутреннего использования.
// 
// Параметры:
//  Форма - см. УправлениеДоступомСлужебныйКлиентСервер.ПараметрыФормыРедактированияРазрешенныхЗначений
//  Элемент - ТаблицаФормы
//  ВыбранноеЗначение - Произвольный
//  СтандартнаяОбработка - Булево
//
Процедура ЗначениеДоступаОбработкаВыбора(Форма, Элемент, ВыбранноеЗначение, СтандартнаяОбработка) Экспорт
	
	ТекущиеДанные = Форма.Элементы.ЗначенияДоступа.ТекущиеДанные;
	
	Если ВыбранноеЗначение = Тип("СправочникСсылка.Пользователи")
	 Или ВыбранноеЗначение = Тип("СправочникСсылка.ГруппыПользователей") Тогда
	
		СтандартнаяОбработка = Ложь;
		
		ПараметрыФормы = Новый Структура;
		ПараметрыФормы.Вставить("РежимВыбора", Истина);
		ПараметрыФормы.Вставить("ТекущаяСтрока", ТекущиеДанные.ЗначениеДоступа);
		ПараметрыФормы.Вставить("ВыборГруппПользователей", Истина);
		
		ОткрытьФорму("Справочник.Пользователи.ФормаВыбора", ПараметрыФормы, Элемент);
		
	ИначеЕсли ВыбранноеЗначение = Тип("СправочникСсылка.ВнешниеПользователи")
	      Или ВыбранноеЗначение = Тип("СправочникСсылка.ГруппыВнешнихПользователей") Тогда
	
		СтандартнаяОбработка = Ложь;
		
		ПараметрыФормы = Новый Структура;
		ПараметрыФормы.Вставить("РежимВыбора", Истина);
		ПараметрыФормы.Вставить("ТекущаяСтрока", ТекущиеДанные.ЗначениеДоступа);
		ПараметрыФормы.Вставить("ВыборГруппВнешнихПользователей", Истина);
		
		ОткрытьФорму("Справочник.ВнешниеПользователи.ФормаВыбора", ПараметрыФормы, Элемент);
	КонецЕсли;
	
КонецПроцедуры

// Только для внутреннего использования.
Процедура ЗначенияДоступаПриОкончанииРедактирования(Форма, Элемент, НоваяСтрока, ОтменаРедактирования) Экспорт
	
	Если Форма.ТекущийВидДоступа = Неопределено Тогда
		Параметры = ПараметрыФормыРедактированияРазрешенныхЗначений(Форма);
		
		Отбор = Новый Структура("ВидДоступа", Неопределено);
		
		НайденныеСтроки = Параметры.ЗначенияДоступа.НайтиСтроки(Отбор);
		
		Для каждого Строка Из НайденныеСтроки Цикл
			Параметры.ЗначенияДоступа.Удалить(Строка);
		КонецЦикла;
		
		ОтменаРедактирования = Истина;
	КонецЕсли;
	
	Если ОтменаРедактирования Тогда
		УправлениеДоступомСлужебныйКлиентСервер.ПриИзмененииТекущегоВидаДоступа(Форма);
	КонецЕсли;
	
КонецПроцедуры

// Только для внутреннего использования.
// 
// Параметры:
//  Форма - см. УправлениеДоступомСлужебныйКлиентСервер.ПараметрыФормыРедактированияРазрешенныхЗначений
//  Элемент - ПолеФормы
//  СтандартнаяОбработка - Булево
//
Процедура ЗначениеДоступаОчистка(Форма, Элемент, СтандартнаяОбработка) Экспорт
	
	Элементы = Форма.Элементы;
	
	СтандартнаяОбработка = Ложь;
	Форма.ТекущийТипВыбираемыхЗначений = Неопределено;
	Элементы.ЗначенияДоступаЗначениеДоступа.КнопкаОчистки = Ложь;
	
	Если Форма.ТекущиеТипыВыбираемыхЗначений.Количество() > 1
	   И Форма.ТекущийВидДоступа <> Форма.ВидДоступаВнешниеПользователи
	   И Форма.ТекущийВидДоступа <> Форма.ВидДоступаПользователи Тогда
		
		Элементы.ЗначенияДоступаЗначениеДоступа.КнопкаВыбора = Истина;
		Элементы.ЗначенияДоступа.ТекущиеДанные.ЗначениеДоступа = Неопределено;
	Иначе
		Элементы.ЗначенияДоступаЗначениеДоступа.КнопкаВыбора = Неопределено;
		Элементы.ЗначенияДоступа.ТекущиеДанные.ЗначениеДоступа = Форма.ТекущиеТипыВыбираемыхЗначений[0].Значение;
	КонецЕсли;
	
КонецПроцедуры

// Только для внутреннего использования.
Процедура ЗначениеДоступаАвтоПодбор(Форма, Элемент, Текст, ДанныеВыбора, Ожидание, СтандартнаяОбработка) Экспорт
	
	СформироватьДанныеВыбораЗначенияДоступа(Форма, Текст, ДанныеВыбора, СтандартнаяОбработка);
	
КонецПроцедуры

// Только для внутреннего использования.
Процедура ЗначениеДоступаОкончаниеВводаТекста(Форма, Элемент, Текст, ДанныеВыбора, СтандартнаяОбработка) Экспорт
	
	СформироватьДанныеВыбораЗначенияДоступа(Форма, Текст, ДанныеВыбора, СтандартнаяОбработка);
	
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// Обработчики событий таблицы формы ВидыДоступа.

// Только для внутреннего использования.
Процедура ВидыДоступаПриАктивизацииСтроки(Форма, Элемент) Экспорт
	
	УправлениеДоступомСлужебныйКлиентСервер.ПриИзмененииТекущегоВидаДоступа(Форма);
	
КонецПроцедуры

// Только для внутреннего использования.
// 
// Параметры:
//  Форма - см. УправлениеДоступомСлужебныйКлиентСервер.ПараметрыФормыРедактированияРазрешенныхЗначений
//  Элемент - ТаблицаФормы
//
Процедура ВидыДоступаПриАктивизацииЯчейки(Форма, Элемент) Экспорт
	
	Если Форма.ЭтоПрофильГруппДоступа Тогда
		Возврат;
	КонецЕсли;
	
	Элементы = Форма.Элементы;
	
	Если Элементы.ВидыДоступа.ТекущийЭлемент <> Элементы.ВидыДоступаВсеРазрешеныПредставление Тогда
		Элементы.ВидыДоступа.ТекущийЭлемент = Элементы.ВидыДоступаВсеРазрешеныПредставление;
	КонецЕсли;
	
КонецПроцедуры

// Только для внутреннего использования.
Процедура ВидыДоступаПередНачаломДобавления(Форма, Элемент, Отказ, Копирование, Родитель, Группа) Экспорт
	
	Если Копирование Тогда
		Отказ = Истина;
	КонецЕсли;
	
КонецПроцедуры

// Только для внутреннего использования.
Процедура ВидыДоступаПередУдалением(Форма, Элемент, Отказ) Экспорт
	
	Форма.ТекущийВидДоступа = Неопределено;
	
КонецПроцедуры

// Только для внутреннего использования.
// 
// Параметры:
//  Форма - см. УправлениеДоступомСлужебныйКлиентСервер.ПараметрыФормыРедактированияРазрешенныхЗначений
//  Элемент - ТаблицаФормы
//  НоваяСтрока - Булево
//  Копирование - Булево
//
Процедура ВидыДоступаПриНачалеРедактирования(Форма, Элемент, НоваяСтрока, Копирование) Экспорт
	
	ТекущиеДанные = Форма.Элементы.ВидыДоступа.ТекущиеДанные;
	Если ТекущиеДанные = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	Если НоваяСтрока Тогда
		ТекущиеДанные.Используется = Истина;
	КонецЕсли;
	
	УправлениеДоступомСлужебныйКлиентСервер.ЗаполнитьВсеРазрешеныПредставление(Форма, ТекущиеДанные, Ложь);
	
КонецПроцедуры

// Только для внутреннего использования.
Процедура ВидыДоступаПриОкончанииРедактирования(Форма, Элемент, НоваяСтрока, ОтменаРедактирования) Экспорт
	
	УправлениеДоступомСлужебныйКлиентСервер.ПриИзмененииТекущегоВидаДоступа(Форма);
	
КонецПроцедуры

// Только для внутреннего использования.
// 
// Параметры:
//  Форма - см. УправлениеДоступомСлужебныйКлиентСервер.ПараметрыФормыРедактированияРазрешенныхЗначений
//  Элемент - ПолеФормы
//
Процедура ВидыДоступаВидДоступаПредставлениеПриИзменении(Форма, Элемент) Экспорт
	
	ТекущиеДанные = Форма.Элементы.ВидыДоступа.ТекущиеДанные;
	Если ТекущиеДанные = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	Если ТекущиеДанные.ВидДоступаПредставление = "" Тогда
		ТекущиеДанные.ВидДоступа   = Неопределено;
		ТекущиеДанные.Используется = Истина;
	КонецЕсли;
	
	УправлениеДоступомСлужебныйКлиентСервер.ЗаполнитьСвойстваВидовДоступаВФорме(Форма);
	УправлениеДоступомСлужебныйКлиентСервер.ПриИзмененииТекущегоВидаДоступа(Форма);
	
КонецПроцедуры

// Только для внутреннего использования.
// 
// Параметры:
//  Форма - см. УправлениеДоступомСлужебныйКлиентСервер.ПараметрыФормыРедактированияРазрешенныхЗначений
//  Элемент - ПолеФормы
//  ВыбранноеЗначение - Произвольный
//  СтандартнаяОбработка - Булево
// 
Процедура ВидыДоступаВидДоступаПредставлениеОбработкаВыбора(Форма, Элемент, ВыбранноеЗначение, СтандартнаяОбработка) Экспорт
	
	ТекущиеДанные = Форма.Элементы.ВидыДоступа.ТекущиеДанные;
	Если ТекущиеДанные = Неопределено Тогда
		СтандартнаяОбработка = Ложь;
		Возврат;
	КонецЕсли;
	
	Параметры = ПараметрыФормыРедактированияРазрешенныхЗначений(Форма);
	
	Отбор = Новый Структура("ВидДоступаПредставление", ВыбранноеЗначение);
	Строки = Параметры.ВидыДоступа.НайтиСтроки(Отбор);
	
	Если Строки.Количество() > 0
	   И Строки[0].ПолучитьИдентификатор() <> Форма.Элементы.ВидыДоступа.ТекущаяСтрока Тогда
		
		ПоказатьПредупреждение(, СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru = 'Вид доступа ""%1"" уже выбран.
			           |Выберите другой.'"),
			ВыбранноеЗначение));
		
		СтандартнаяОбработка = Ложь;
		Возврат;
	КонецЕсли;
	
	Отбор = Новый Структура("Представление", ВыбранноеЗначение);
	ТекущиеДанные.ВидДоступа = Форма.ВсеВидыДоступа.НайтиСтроки(Отбор)[0].Ссылка;
	
КонецПроцедуры

// Только для внутреннего использования.
// 
// Параметры:
//  Форма - см. УправлениеДоступомСлужебныйКлиентСервер.ПараметрыФормыРедактированияРазрешенныхЗначений
//  Элемент - ПолеФормы
//
Процедура ВидыДоступаВсеРазрешеныПредставлениеПриИзменении(Форма, Элемент) Экспорт
	
	ТекущиеДанные = Форма.Элементы.ВидыДоступа.ТекущиеДанные;
	Если ТекущиеДанные = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	Если ТекущиеДанные.ВсеРазрешеныПредставление = "" Тогда
		ТекущиеДанные.ВсеРазрешены = Ложь;
		Если Форма.ЭтоПрофильГруппДоступа Тогда
			ТекущиеДанные.Предустановленный = Ложь;
		КонецЕсли;
	КонецЕсли;
	
	Если Форма.ЭтоПрофильГруппДоступа Тогда
		УправлениеДоступомСлужебныйКлиентСервер.ПриИзмененииТекущегоВидаДоступа(Форма);
		УправлениеДоступомСлужебныйКлиентСервер.ЗаполнитьВсеРазрешеныПредставление(Форма, ТекущиеДанные, Ложь);
	Иначе
		Форма.Элементы.ВидыДоступа.ЗакончитьРедактированиеСтроки(Ложь);
		УправлениеДоступомСлужебныйКлиентСервер.ЗаполнитьВсеРазрешеныПредставление(Форма, ТекущиеДанные);
	КонецЕсли;
	
КонецПроцедуры

// Только для внутреннего использования.
// 
// Параметры:
//  Форма - см. УправлениеДоступомСлужебныйКлиентСервер.ПараметрыФормыРедактированияРазрешенныхЗначений
//  Элемент - ПолеФормы
//  ВыбранноеЗначение - Произвольный
//  СтандартнаяОбработка - Булево
//
Процедура ВидыДоступаВсеРазрешеныПредставлениеОбработкаВыбора(Форма, Элемент, ВыбранноеЗначение, СтандартнаяОбработка) Экспорт
	
	ТекущиеДанные = Форма.Элементы.ВидыДоступа.ТекущиеДанные;
	Если ТекущиеДанные = Неопределено Тогда
		СтандартнаяОбработка = Ложь;
		Возврат;
	КонецЕсли;
	
	Отбор = Новый Структура("Представление", ВыбранноеЗначение);
	Имя = Форма.ПредставленияВсеРазрешены.НайтиСтроки(Отбор)[0].Имя;
	
	Если Форма.ЭтоПрофильГруппДоступа Тогда
		ТекущиеДанные.Предустановленный = (Имя = "ВсеРазрешены" ИЛИ Имя = "ВсеЗапрещены");
	КонецЕсли;
	
	ТекущиеДанные.ВсеРазрешены = (Имя = "ВначалеВсеРазрешены" ИЛИ Имя = "ВсеРазрешены");
	
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// Обработчики событий общей формы ФормаОтчета.

// Обработчик двойного щелчка мыши, нажатия клавиши Enter или гиперссылки в табличном документе формы отчета.
// См. "Расширение поля формы для поля табличного документа.Выбор" в синтакс-помощнике.
//
// Параметры:
//   ФормаОтчета          - ФормаКлиентскогоПриложения - форма отчета.
//   Элемент              - ПолеФормы        - табличный документ.
//   Область              - ОбластьЯчеекТабличногоДокумента - выбранное значение.
//   СтандартнаяОбработка - Булево - признак выполнения стандартной обработки события.
//
Процедура ОбработкаВыбораТабличногоДокумента(ФормаОтчета, Элемент, Область, СтандартнаяОбработка) Экспорт
	
	Если ФормаОтчета.НастройкиОтчета.ПолноеИмя <> "Отчет.АнализПравДоступа" Тогда
		Возврат;
	КонецЕсли;
	
	Если ТипЗнч(Область) = Тип("ОбластьЯчеекТабличногоДокумента")
		И Область.ТипОбласти = ТипОбластиЯчеекТабличногоДокумента.Прямоугольник
		И Область.Расшифровка <> Неопределено Тогда
		
		ФормаОтчета.ОбработкаРасшифровки = Истина;
	КонецЕсли;
	
КонецПроцедуры

// См. ОтчетыКлиентПереопределяемый.ОбработкаРасшифровки
Процедура ПриОбработкеРасшифровки(ФормаОтчета, Элемент, Расшифровка, СтандартнаяОбработка) Экспорт
	
	Если ФормаОтчета.НастройкиОтчета.ПолноеИмя <> "Отчет.АнализПравДоступа" Тогда
		Возврат;
	КонецЕсли;
	
	СтандартнаяОбработка = Ложь;
	ПараметрыРасшифровки = УправлениеДоступомСлужебныйВызовСервера.ПараметрыРасшифровкиОтчетаАнализПравДоступа(ФормаОтчета.ОтчетДанныеРасшифровки, Расшифровка);
	
	ПараметрыОтчета = Новый Структура;
	ПараметрыОтчета.Вставить("СформироватьПриОткрытии", Истина);
	ПараметрыОтчета.Вставить("Расшифровка", Расшифровка);
	
	Отбор = Новый Структура;
	Для Каждого Элемент Из ФормаОтчета.Отчет.КомпоновщикНастроек.Настройки.Отбор.Элементы Цикл
		Настройка = ФормаОтчета.Отчет.КомпоновщикНастроек.ПользовательскиеНастройки.Элементы.Найти(Элемент.ИдентификаторПользовательскойНастройки);
		Если Настройка = Неопределено Тогда
			Настройка = Элемент;
		КонецЕсли;
		Если Настройка.Использование Тогда
			Если Элемент.ВидСравнения = ВидСравненияКомпоновкиДанных.Равно Или Элемент.ВидСравнения = ВидСравненияКомпоновкиДанных.ВСписке Тогда
				Отбор.Вставить(Элемент.ЛевоеЗначение, Настройка.ПравоеЗначение);
			КонецЕсли;
		КонецЕсли;
	КонецЦикла;
	
	ИмяПараметра = "Пользователь";
	ЗначениеПараметра = ЗначениеПараметра(ФормаОтчета.Отчет.КомпоновщикНастроек, ИмяПараметра);
	Если ЗначениеЗаполнено(ЗначениеПараметра) Тогда
		Отбор.Вставить(ИмяПараметра, ЗначениеПараметра);
	КонецЕсли;
	
	Если ФормаОтчета.КлючТекущегоВарианта = "ПраваПользователейНаТаблицыОтчета" И ПараметрыРасшифровки.ИмяПоляРасшифровки <> "Пользователь"
		Или ФормаОтчета.КлючТекущегоВарианта = "ПраваПользователяНаТаблицыОтчета" Тогда
		Отбор.Удалить("Отчет");
	КонецЕсли;
	
	Если ПараметрыРасшифровки.ИмяПоляРасшифровки = "Право"
		Или СтрНачинаетсяС(ПараметрыРасшифровки.ИмяПоляРасшифровки, "Картинка") Тогда
		
		КлючВарианта = "ПраваПользователяНаТаблицу";
		
		Если ПараметрыРасшифровки.СписокПолей["Пользователь"] <> Неопределено Тогда
			Отбор.Вставить("Пользователь", ПараметрыРасшифровки.СписокПолей["Пользователь"]);
		КонецЕсли;
		
		Если ПараметрыРасшифровки.СписокПолей["ОбъектМетаданных"] <> Неопределено Тогда
			Отбор.Вставить("ОбъектМетаданных", ПараметрыРасшифровки.СписокПолей["ОбъектМетаданных"]);
		ИначеЕсли ПараметрыРасшифровки.СписокПолей["Отчет"] <> Неопределено Тогда
			Отбор.Вставить("Отчет", ПараметрыРасшифровки.СписокПолей["Отчет"]);
			КлючВарианта = "ПраваПользователяНаТаблицыОтчета";
		КонецЕсли;
		
		Если КлючВарианта = ФормаОтчета.КлючТекущегоВарианта Тогда
			Возврат;
		КонецЕсли;
		
	ИначеЕсли ПараметрыРасшифровки.ИмяПоляРасшифровки = "ОбъектМетаданных" Тогда
		
		КлючВарианта = "ПраваПользователейНаТаблицу";
		Отбор.Вставить("ОбъектМетаданных", ПараметрыРасшифровки.СписокПолей["ОбъектМетаданных"]);

		Если ФормаОтчета.КлючТекущегоВарианта = "ПраваПользователяНаТаблицы"
			Или ФормаОтчета.КлючТекущегоВарианта = "ПраваПользователяНаТаблицыОтчета" Тогда
			КлючВарианта = "ПраваПользователяНаТаблицу";
		КонецЕсли;
		
	ИначеЕсли ПараметрыРасшифровки.ИмяПоляРасшифровки = "Пользователь" 
		И ФормаОтчета.КлючТекущегоВарианта <> "ПраваПользователяНаТаблицы"
		И ФормаОтчета.КлючТекущегоВарианта <> "ПраваПользователяНаТаблицу"
		И ФормаОтчета.КлючТекущегоВарианта <> "ПраваПользователяНаТаблицыОтчетов" Тогда
		
		КлючВарианта = "ПраваПользователяНаТаблицы";
		Отбор.Вставить("Пользователь", ПараметрыРасшифровки.СписокПолей["Пользователь"]);
		Отбор.Удалить("ВходВПрограммуРазрешен");
		
		Если ФормаОтчета.КлючТекущегоВарианта = "ПраваПользователейНаТаблицу" Тогда
			КлючВарианта = "ПраваПользователяНаТаблицу";
		КонецЕсли;
		
		Если ФормаОтчета.КлючТекущегоВарианта = "ПраваПользователейНаТаблицыОтчета" Тогда
			КлючВарианта = "ПраваПользователяНаТаблицыОтчета";
		КонецЕсли;
		
		Если ФормаОтчета.КлючТекущегоВарианта = "АнализПравДоступа" И ГруппировкаПоОтчетамВключена(ФормаОтчета.Отчет.КомпоновщикНастроек) Тогда
			КлючВарианта = "ПраваПользователяНаТаблицыОтчетов";
		КонецЕсли;
		
	ИначеЕсли ПараметрыРасшифровки.ИмяПоляРасшифровки = "Отчет" Тогда
		
		Если ФормаОтчета.КлючТекущегоВарианта = "ПраваПользователяНаТаблицыОтчета"
			Или ФормаОтчета.КлючТекущегоВарианта = "ПраваПользователейНаТаблицыОтчета" Тогда
			Возврат;
		КонецЕсли;
		
		КлючВарианта = "ПраваПользователейНаТаблицыОтчета";
		Отбор.Вставить("Отчет", ПараметрыРасшифровки.СписокПолей["Отчет"]);
		
	Иначе
		
		ЗначениеРасшифровки = ПараметрыРасшифровки.СписокПолей[ПараметрыРасшифровки.ИмяПоляРасшифровки];
		Если ЗначениеЗаполнено(ЗначениеРасшифровки) Тогда
			Пользователь = ПараметрыРасшифровки.СписокПолей["Пользователь"];
			Если Пользователь = Неопределено И Отбор.Свойство("Пользователь") И ТипЗнч(Отбор.Пользователь) = Тип("СправочникСсылка.Пользователи") Тогда
				Пользователь = Отбор.Пользователь;
			КонецЕсли;
				
			Если ЗначениеЗаполнено(Пользователь) И ТипЗнч(ЗначениеРасшифровки) = Тип("СправочникСсылка.ПрофилиГруппДоступа") Тогда
				ПараметрыРаботыКлиента = СтандартныеПодсистемыКлиент.ПараметрыРаботыКлиента();
				Если ПараметрыРаботыКлиента.УпрощенныйИнтерфейсНастройкиПравДоступа Тогда
					ИмяФормы = "ОбщаяФорма.ПраваДоступаУпрощенно";
				Иначе
					ИмяФормы = "ОбщаяФорма.ПраваДоступа";
				КонецЕсли;
				
				Форма = ОткрытьФорму("Справочник.Пользователи.ФормаОбъекта", Новый Структура("Ключ", Пользователь));
				ОткрытьФорму(ИмяФормы, Новый Структура("Пользователь", Пользователь), Форма, , Форма.Окно);
			Иначе
				ПоказатьЗначение(Неопределено, ПараметрыРасшифровки.СписокПолей[ПараметрыРасшифровки.ИмяПоляРасшифровки]);
			КонецЕсли;
		КонецЕсли;
		
		Возврат;
		
	КонецЕсли;
	
	ПараметрыОтчета.Вставить("Отбор", Отбор);
	ПараметрыОтчета.Вставить("КлючВарианта", КлючВарианта);
	ПараметрыОтчета.Вставить("КлючНазначенияИспользования", КлючВарианта);
	
	ОткрытьФорму("Отчет.АнализПравДоступа.Форма", ПараметрыОтчета, ФормаОтчета);
	
КонецПроцедуры

Процедура ПоказатьПраваПользователейОтчета(Отчет, ИспользуемыеТаблицы) Экспорт
	
	КлючВарианта = "ПраваПользователейНаТаблицыОтчета";
	
	Отбор = Новый Структура;
	Отбор.Вставить("Отчет", Отчет);
	Отбор.Вставить("ВходВПрограммуРазрешен", Истина);
	
	ПараметрыОтчета = Новый Структура;
	ПараметрыОтчета.Вставить("СформироватьПриОткрытии", Истина);
	ПараметрыОтчета.Вставить("Отбор", Отбор);
	ПараметрыОтчета.Вставить("КлючВарианта", КлючВарианта);
	ПараметрыОтчета.Вставить("КлючНазначенияИспользования", КлючВарианта);
	ПараметрыОтчета.Вставить("ИспользуемыеТаблицы", ИспользуемыеТаблицы);
	
	ОткрытьФорму("Отчет.АнализПравДоступа.Форма", ПараметрыОтчета, ЭтотОбъект);
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

// Продолжение обработчика события ЗначениеДоступаНачалоВыбора.
Процедура ЗначениеДоступаНачалоВыбораПродолжение(ВыбранныйЭлемент, Форма) Экспорт
	
	Если ВыбранныйЭлемент <> Неопределено Тогда
		Форма.ТекущийТипВыбираемыхЗначений = ВыбранныйЭлемент.Значение;
		ЗначениеДоступаНачалоВыбораЗавершение(Форма);
	КонецЕсли;
	
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// Вспомогательные процедуры и функции.

// Завершение обработчика события ЗначениеДоступаНачалоВыбора.
// 
// Параметры:
//  Форма - см. УправлениеДоступомСлужебныйКлиентСервер.ПараметрыФормыРедактированияРазрешенныхЗначений
//
Процедура ЗначениеДоступаНачалоВыбораЗавершение(Форма)
	
	Элементы = Форма.Элементы;
	Элемент  = Элементы.ЗначенияДоступаЗначениеДоступа;
	ТекущиеДанные = Элементы.ЗначенияДоступа.ТекущиеДанные;
	
	Если НЕ ЗначениеЗаполнено(ТекущиеДанные.ЗначениеДоступа)
	   И ТекущиеДанные.ЗначениеДоступа <> Форма.ТекущийТипВыбираемыхЗначений Тогда
		
		ТекущиеДанные.ЗначениеДоступа = Форма.ТекущийТипВыбираемыхЗначений;
	КонецЕсли;
	
	Элементы.ЗначенияДоступаЗначениеДоступа.КнопкаВыбора = Неопределено;
	Элементы.ЗначенияДоступаЗначениеДоступа.КнопкаОчистки
		= Форма.ТекущийТипВыбираемыхЗначений <> Неопределено
		И Форма.ТекущиеТипыВыбираемыхЗначений.Количество() > 1;
	
	ПараметрыФормы = Новый Структура;
	ПараметрыФормы.Вставить("РежимВыбора", Истина);
	ПараметрыФормы.Вставить("ТекущаяСтрока", ТекущиеДанные.ЗначениеДоступа);
	ПараметрыФормы.Вставить("ЭтоВыборЗначенияДоступа");
	
	Если Форма.ТекущийВидДоступа = Форма.ВидДоступаПользователи Тогда
		ПараметрыФормы.Вставить("ВыборГруппПользователей", Истина);
		ОткрытьФорму("Справочник.Пользователи.ФормаВыбора", ПараметрыФормы, Элемент);
		Возврат;
		
	ИначеЕсли Форма.ТекущийВидДоступа = Форма.ВидДоступаВнешниеПользователи Тогда
		ПараметрыФормы.Вставить("ВыборГруппВнешнихПользователей", Истина);
		ОткрытьФорму("Справочник.ВнешниеПользователи.ФормаВыбора", ПараметрыФормы, Элемент);
		Возврат;
	КонецЕсли;
	
	Отбор = Новый Структура("ТипЗначений", Форма.ТекущийТипВыбираемыхЗначений);
	НайденныеСтроки = Форма.ВсеТипыВыбираемыхЗначений.НайтиСтроки(Отбор);
	
	Если НайденныеСтроки.Количество() = 0 Тогда
		Возврат;
	КонецЕсли;
	
	Если НайденныеСтроки[0].ИерархияЭлементов Тогда
		ПараметрыФормы.Вставить("ВыборГруппИЭлементов", ИспользованиеГруппИЭлементов.ГруппыИЭлементы);
	КонецЕсли;
	
	ОткрытьФорму(НайденныеСтроки[0].ИмяТаблицы + ".ФормаВыбора", ПараметрыФормы, Элемент);
	
КонецПроцедуры

// Обслуживание таблиц ВидыДоступа и ЗначенияДоступа в формах редактирования.

Функция ПараметрыФормыРедактированияРазрешенныхЗначений(Форма, ТекущийОбъект = Неопределено)
	
	Возврат УправлениеДоступомСлужебныйКлиентСервер.ПараметрыФормыРедактированияРазрешенныхЗначений(
		Форма, ТекущийОбъект);
	
КонецФункции

Процедура СформироватьДанныеВыбораЗначенияДоступа(Форма, Текст, ДанныеВыбора, СтандартнаяОбработка)
	
	Если Не ЗначениеЗаполнено(Текст) Тогда
		Возврат;
	КонецЕсли;
		
	Если Форма.ТекущийВидДоступа <> Форма.ВидДоступаВнешниеПользователи
	   И Форма.ТекущийВидДоступа <> Форма.ВидДоступаПользователи Тогда
		Возврат;
	КонецЕсли;
	
	СтандартнаяОбработка = Ложь;
	
	ДанныеВыбора = УправлениеДоступомСлужебныйВызовСервера.СформироватьДанныеВыбораПользователя(Текст,
		Ложь,
		Форма.ТекущийВидДоступа = Форма.ВидДоступаВнешниеПользователи,
		Форма.ТекущийВидДоступа <> Форма.ВидДоступаПользователи);
	
КонецПроцедуры

Функция ГруппировкаПоОтчетамВключена(КомпоновщикНастроек)
	
	Результат = Ложь;
	
	Элемент = НайтиЭлементГруппировкиПоИмени(КомпоновщикНастроек.Настройки.Структура, "ГруппировкаПоОтчетам");
	Если Элемент <> Неопределено Тогда
		Настройка = КомпоновщикНастроек.ПользовательскиеНастройки.Элементы.Найти(Элемент.ИдентификаторПользовательскойНастройки);
		Если Настройка <> Неопределено Тогда
			Результат = Настройка.Использование;
		КонецЕсли;
	КонецЕсли;
	
	Возврат Результат;
	
КонецФункции

Функция НайтиЭлементГруппировкиПоИмени(КоллекцияЭлементов, Имя)
	
	Результат = Неопределено;
	
	Для Каждого Элемент Из КоллекцияЭлементов Цикл
		Если (ТипЗнч(Элемент) = Тип("ГруппировкаКомпоновкиДанных")
			Или ТипЗнч(Элемент) = Тип("ГруппировкаТаблицыКомпоновкиДанных"))
			И Элемент.Имя = Имя Тогда
			Результат = Элемент;
		ИначеЕсли ТипЗнч(Элемент) = Тип("ТаблицаКомпоновкиДанных") Тогда
			Результат = НайтиЭлементГруппировкиПоИмени(Элемент.Строки, Имя);
			Если Результат = Неопределено Тогда
				Результат = НайтиЭлементГруппировкиПоИмени(Элемент.Колонки, Имя);
			КонецЕсли;
		КонецЕсли;
		Если Результат <> Неопределено Тогда
			Возврат Результат;
		КонецЕсли;
	КонецЦикла;
	
	Возврат Результат;
	
КонецФункции

Функция ЗначениеПараметра(КомпоновщикНастроек, ИмяПараметра)
	
	Параметр = КомпоновщикНастроек.Настройки.ПараметрыДанных.Элементы.Найти(ИмяПараметра);
	Настройка = КомпоновщикНастроек.ПользовательскиеНастройки.Элементы.Найти(Параметр.ИдентификаторПользовательскойНастройки);
	
	Если Настройка <> Неопределено И Настройка.Использование Тогда
		Возврат Настройка.Значение;
	КонецЕсли;
	
	Возврат Параметр.Значение;
	
КонецФункции

#КонецОбласти
