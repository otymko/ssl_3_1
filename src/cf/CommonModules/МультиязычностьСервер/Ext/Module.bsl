﻿///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2019, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область ПрограммныйИнтерфейс

// Для вызова из обработчика ПриНачальномЗаполненииЭлементов.
// Заполняет колонки с именами ИмяРеквизита_<КодЯзыка> текстовыми значениями для указанных кодов языков.
//
// Параметры:
//  Элемент        - СтрокаТаблицыЗначений - заполняемая строка таблицы. С колонками ИмяРеквизита_КодЯзыка.
//  ИмяРеквизита   - Строка -  имя реквизита. Например, "Наименование"
//  ИсходнаяСтрока - Строка - строка в формате НСтр. Например, "ru = 'Сообщение на русском'; en = 'English message'".
//  КодыЯзыков     - Массив - коды языков, на которых нужно заполнить строки.
// 
// Пример:
//
//  МультиязычностьСервер.ЗаполнитьМультиязычныйРеквизит(Элемент, "Наименование", "ru = 'Сообщение на русском'; en =
//  'English message'", КодыЯзыков);
//
Процедура ЗаполнитьМультиязычныйРеквизит(Элемент, ИмяРеквизита, ИсходнаяСтрока, КодыЯзыков = Неопределено) Экспорт
	
	Для каждого КодЯзыка Из КодыЯзыков Цикл
		Элемент[ИмяЛокализуемогоРеквизита(ИмяРеквизита, КодЯзыка)] = НСтр(ИсходнаяСтрока, КодЯзыка);
	КонецЦикла;
	
КонецПроцедуры

// Вызывается из обработчика ПриСозданииНаСервере формы объекта для добавления кнопки открытия у поле мультиязычных реквизитов,
// нажатие на которую открывает форму ввода значений реквизита на используемых языках конфигурации.
//
// Параметры:
//    Форма                - ФормаКлиентскогоПриложения - форма содержащая мультиязычные реквизиты.
//    Объект               - Произвольный - Объект-владелец мультиязычных реквизитов.
//
Процедура ПриСозданииНаСервере(Форма, Объект = Неопределено) Экспорт
	
	Если Объект <> Неопределено И МультиязычностьПовтИсп.КонфигурацияИспользуетТолькоОдинЯзык(Объект.Свойство("Представления")) Тогда
		Возврат;
	КонецЕсли;
	
	ТипФормы = МультиязычностьПовтИсп.ОпределитьТипФормы(Форма.ИмяФормы);
	
	Если Объект = Неопределено Тогда
		Если ТипФормы = "ОсновнаяФормаСписка" Или ТипФормы = "ОсновнаяФормаВыбора" Тогда
			ИзменениеТекстаЗапросаСпискаДляТекущегоЯзыка(Форма);
		КонецЕсли;
		Возврат;
	КонецЕсли;
	
	СписокРеквизитовФормы = Форма.ПолучитьРеквизиты();
	СоздатьПараметрыМультиязычныхРеквизитов = Истина;
	Для Каждого Реквизит Из СписокРеквизитовФормы Цикл
		Если Реквизит.Имя = "ПараметрыМультиязычныхРеквизитов" Тогда
			СоздатьПараметрыМультиязычныхРеквизитов = Ложь;
		КонецЕсли;
	КонецЦикла;
	
	Если СоздатьПараметрыМультиязычныхРеквизитов Тогда
		ДобавляемыеРеквизиты = Новый Массив;
		ДобавляемыеРеквизиты.Добавить(Новый РеквизитФормы("ПараметрыМультиязычныхРеквизитов", Новый ОписаниеТипов(),,, Истина));
		Форма.ИзменитьРеквизиты(ДобавляемыеРеквизиты);
	КонецЕсли;
	
	Форма.ПараметрыМультиязычныхРеквизитов = Новый Структура;
	
	НаименованияРеквизитов = НаименованияЛокализуемыхРеквизитыОбъекта(Объект.Ссылка.Метаданные(), "Объект.");
	
	Для каждого Элемент Из Форма.Элементы Цикл
		
		Если ТипЗнч(Элемент) = Тип("ПолеФормы") И НаименованияРеквизитов[Элемент.ПутьКДанным] = Истина Тогда
			Элемент.КнопкаОткрытия = Истина;
			Элемент.УстановитьДействие("Открытие", "Подключаемый_Открытие");
			Форма.ПараметрыМультиязычныхРеквизитов.Вставить(Элемент.Имя, Элемент.ПутьКДанным);
		КонецЕсли;
		
	КонецЦикла;
	
КонецПроцедуры

// Вызывается из обработчика ПриЧтениеНаСервере формы объекта для заполнения значений мультиязычных
// реквизитов формы на текущем языке пользователя.
//
// Параметры:
//  Форма         - ФормаКлиентскогоПриложения - Форма объекта.
//  ТекущийОбъект - Произвольный - Объект, который был получен в обработчике формы ПриЧтенииНаСервере.
//
Процедура ПриЧтенииНаСервере(Форма, ТекущийОбъект) Экспорт
	
	Если ЭтоОсновнойЯзык() Тогда
		Возврат;
	КонецЕсли;
	
	ТекущийОбъект.ПриЧтенииПредставленийНаСервере();
	Форма.ЗначениеВРеквизитФормы(ТекущийОбъект, "Объект");
	
КонецПроцедуры

// Вызывается из обработчика ПередЗаписьюНаСервере формы объекта или при программной записи объекта
// для записи значений мультиязычных реквизитов в соответствии с текущим языком пользователя.
//
// Параметры:
//  ТекущийОбъект - Произвольный - Записываемый объект.
//
Процедура ПередЗаписьюНаСервере(ТекущийОбъект) Экспорт
	
	Если ТекущийЯзык().КодЯзыка = ОбщегоНазначения.КодОсновногоЯзыка() Тогда
		Возврат;
	КонецЕсли;
	
	Если МультиязычныеСтрокиВРеквизитах(ТекущийОбъект.Метаданные()) Тогда
		
		СуффиксТекущегоЯзыка  = "";
		
		Если СтрСравнить(ОбщегоНазначения.КодОсновногоЯзыка(), ТекущийЯзык().КодЯзыка) <> 0 Тогда
			СуффиксТекущегоЯзыка = СуффиксТекущегоЯзыка();
		КонецЕсли;
		
		ИменаЛокализуемыхРеквизитов = НаименованияЛокализуемыхРеквизитыОбъекта(ТекущийОбъект.Ссылка.Метаданные());
		
		Для Каждого Реквизит Из ИменаЛокализуемыхРеквизитов Цикл
			
			Значение = ТекущийОбъект[Реквизит.Ключ];
			ТекущийОбъект[Реквизит.Ключ] = ТекущийОбъект[Реквизит.Ключ + СуффиксТекущегоЯзыка];
			ТекущийОбъект[Реквизит.Ключ + СуффиксТекущегоЯзыка] = Значение;
			
		КонецЦикла;
		
		Возврат;
	КонецЕсли;
	
	Реквизиты = Новый Массив;
	Для каждого Реквизит Из ТекущийОбъект.Ссылка.Метаданные().ТабличныеЧасти.Представления.Реквизиты Цикл
		Если СтрСравнить(Реквизит.Имя, "КодЯзыка") = 0 Тогда
			Продолжить;
		КонецЕсли;
		
		Реквизиты.Добавить(Реквизит.Имя);
	КонецЦикла;
	
	Отбор = Новый Структура();
	Отбор.Вставить("КодЯзыка", ТекущийЯзык().КодЯзыка);
	НайденныеСтроки = ТекущийОбъект.Представления.НайтиСтроки(Отбор);
	
	Если НайденныеСтроки.Количество() > 0 Тогда
		Представление = НайденныеСтроки[0];
	Иначе
		Представление = ТекущийОбъект.Представления.Добавить();
		Представление.КодЯзыка = ТекущийЯзык().КодЯзыка;
	КонецЕсли;
	
	Для каждого ИмяРеквизита Из Реквизиты Цикл
		Представление[ИмяРеквизита] = ТекущийОбъект[ИмяРеквизита];
	КонецЦикла;
	
	Отбор.КодЯзыка = ОбщегоНазначения.КодОсновногоЯзыка();
	НайденныеСтроки = ТекущийОбъект.Представления.НайтиСтроки(Отбор);
	Если НайденныеСтроки.Количество() > 0 Тогда
		Для каждого ИмяРеквизита Из Реквизиты Цикл
			ТекущийОбъект[ИмяРеквизита] = НайденныеСтроки[0][ИмяРеквизита];
		КонецЦикла;
		ТекущийОбъект.Представления.Удалить(НайденныеСтроки[0]);
	КонецЕсли;
	
	ТекущийОбъект.Представления.Свернуть("КодЯзыка", СтрСоединить(Реквизиты, ","));
	
КонецПроцедуры

// Вызывается из модуля объекта для заполнения значений мультиязычных
// реквизитов объекта на текущем языке пользователя.
//
// Параметры:
//  Объект - Произвольный - объект данных.
//
Процедура ПриЧтенииПредставленийНаСервере(Объект) Экспорт
	
	Если ЭтоОсновнойЯзык() Тогда
		Возврат;
	КонецЕсли;
	
	Если МультиязычныеСтрокиВРеквизитах(Объект.Метаданные()) Тогда
		
		СуффиксТекущегоЯзыка  = "";
		
		Если СтрСравнить(Константы.ОсновнойЯзык.Получить(), ТекущийЯзык().КодЯзыка) <> 0 Тогда
			СуффиксТекущегоЯзыка = СуффиксТекущегоЯзыка();
			
		КонецЕсли;
		
		ИменаЛокализуемыхРеквизитов = НаименованияЛокализуемыхРеквизитыОбъекта(Объект.Ссылка.Метаданные());
		
		Для Каждого Реквизит Из ИменаЛокализуемыхРеквизитов Цикл
			
			Значение = Объект[Реквизит.Ключ];
			Объект[Реквизит.Ключ] = Объект[Реквизит.Ключ + СуффиксТекущегоЯзыка];
			Объект[Реквизит.Ключ + СуффиксТекущегоЯзыка] = Значение;
			
			Если ПустаяСтрока(Объект[Реквизит.Ключ]) Тогда
				Объект[Реквизит.Ключ] = Значение;
			КонецЕсли;
			
		КонецЦикла;
		
		Возврат;
		
	КонецЕсли;
	
	Для каждого Реквизит Из Объект.Метаданные().ТабличныеЧасти.Представления.Реквизиты Цикл
		
		Если СтрСравнить(Реквизит.Имя, "КодЯзыка") = 0 Тогда
			Продолжить;
		КонецЕсли;
		
		ИмяРеквизита = Реквизит.Имя;
		
		Отбор = Новый Структура();
		Отбор.Вставить("КодЯзыка", ОбщегоНазначения.КодОсновногоЯзыка());
		НайденныеСтроки = Объект.Представления.НайтиСтроки(Отбор);
	
		Если НайденныеСтроки.Количество() > 0 Тогда
			Представление = НайденныеСтроки[0];
		Иначе
			Представление = Объект.Представления.Добавить();
			Представление.КодЯзыка = ОбщегоНазначения.КодОсновногоЯзыка();
		КонецЕсли;
		Представление[ИмяРеквизита] = Объект[ИмяРеквизита];
		
		Отбор = Новый Структура();
		Отбор.Вставить("КодЯзыка", ТекущийЯзык().КодЯзыка);
		НайденныеСтроки = Объект.Представления.НайтиСтроки(Отбор);
		
		Если НайденныеСтроки.Количество() > 0 И ЗначениеЗаполнено(НайденныеСтроки[0][ИмяРеквизита]) Тогда
			Объект[ИмяРеквизита] = НайденныеСтроки[0][ИмяРеквизита];
		КонецЕсли;
		
	КонецЦикла;
	
КонецПроцедуры

// Вызывается из обработчика ОбработкаПолученияДанныхВыбора для формирования списка при вводе по строке,
// автоподборе текста и быстром выбора, а также при выполнении метода ПолучитьДанныеВыбора.
// Список содержит варианты на всех языках с учетом реквизитов определенных в свойстве ВводПоСтроке.
//
// Параметры:
//  ДанныеВыбора         - СписокЗначений - данные для выбора.
//  Параметры            - Структура - содержит параметры выбора.
//  СтандартнаяОбработка - Булево  - данный параметр передается признак выполнения стандартной (системной) обработки события.
//  ОбъектМетаданных     - ОбъектМетаданных - объект метаданных, для которого формируется список выбора.
//
Процедура ОбработкаПолученияДанныхВыбора(ДанныеВыбора, Знач Параметры, СтандартнаяОбработка, ОбъектМетаданных) Экспорт
	
	Если МультиязычностьПовтИсп.КонфигурацияИспользуетТолькоОдинЯзык(ОбъектМетаданных.ТабличныеЧасти.Найти("Представления") = Неопределено) Тогда
		Возврат;
	КонецЕсли;
	
	СтандартнаяОбработка = Ложь;
	
	ПоляВводаПоСтроке = ОбъектМетаданных.ВводПоСтроке;
	Поля              = Новый Массив;
	
	НаименованияЛокализуемыхРеквизитов = НаименованияЛокализуемыхРеквизитыОбъекта(ОбъектМетаданных);
	Для каждого Поле Из ПоляВводаПоСтроке Цикл
		Если НаименованияЛокализуемыхРеквизитов.Получить(Поле.Имя) = Истина Тогда
			
			Поля.Добавить("Таблица." + Поле.Имя + " ПОДОБНО &СтрокаПоиска");
			
			Если ИспользуетсяПервыйДополнительныйЯзык() Тогда
				Поля.Добавить("Таблица." + Поле.Имя + "Язык1 ПОДОБНО &СтрокаПоиска");
			КонецЕсли;
			
			Если ИспользуетсяВторойДополнительныйЯзык() Тогда
				Поля.Добавить("Таблица." + Поле.Имя + "Язык2 ПОДОБНО &СтрокаПоиска");
			КонецЕсли;

		Иначе
			Поля.Добавить("Таблица." + Поле.Имя + " ПОДОБНО &СтрокаПоиска");
		КонецЕсли;
	КонецЦикла;
	
	ШаблонЗапроса = "ВЫБРАТЬ ПЕРВЫЕ 20
	|	Таблица.Ссылка КАК Ссылка
	|ИЗ
	|	&ИмяОбъекта КАК Таблица
	|ГДЕ
	|	&УсловияОтбора";
	
	ТекстЗапроса = СтрЗаменить(ШаблонЗапроса, "&ИмяОбъекта", ОбъектМетаданных.ПолноеИмя());
	ТекстЗапроса = СтрЗаменить(ТекстЗапроса, "&УсловияОтбора", СтрСоединить(Поля, " ИЛИ "));
	
	Запрос = Новый Запрос(ТекстЗапроса);
	
	Запрос.УстановитьПараметр("СтрокаПоиска", "%" + Параметры.СтрокаПоиска +"%");
	
	РезультатЗапроса = Запрос.Выполнить().Выбрать();
	
	ДанныеВыбора = Новый СписокЗначений;
	Пока РезультатЗапроса.Следующий() Цикл
		ДанныеВыбора.Добавить(РезультатЗапроса.Ссылка, РезультатЗапроса.Ссылка);
	КонецЦикла;
	
КонецПроцедуры

// Добавляет отложенный обработчик обновления, который обновляет значения у мультиязычных реквизитов объекта.
// Следует вызывать, если в процедурах ПриНачальномЗаполненииЭлементов у объектов были изменено содержимое 
// строк заполнения этих реквизитов.  Если пользователь интерактивно изменял значения этих реквизитов,
// то эти изменения будут утеряны.
//
// Параметры:
//  Версия      - Строка          - см. ОбновлениеИнформационнойБазыБСП.ПриДобавленииОбработчиковОбновления.
//  Обработчики - ТаблицаЗначений - см. ОбновлениеИнформационнойБазыБСП.ПриДобавленииОбработчиковОбновления.
//
// Возвращаемое значение:
//  СтрокаТаблицыЗначений - см. ОбновлениеИнформационнойБазыБСП.ПриДобавленииОбработчиковОбновления.
//
// Пример:
//	Процедура ПриДобавленииОбработчиковОбновления(Обработчики) Экспорт
//		МультиязычностьСервер.ДобавитьОбработчикОбновленияПредставленийПредопределенныхЭлементов("3.1.2.73", Обработчики);
//	КонецПроцедуры
//
Функция ДобавитьОбработчикОбновленияПредставленийПредопределенныхЭлементов(Версия, Обработчики) Экспорт
	
	ОбъектыСПредопределеннымиЭлементами = ОбъектыСПредопределеннымиЭлементамиСтрокой();
	
	Обработчик = Обработчики.Добавить();
	Обработчик.Версия = Версия;
	Обработчик.Идентификатор = Новый УникальныйИдентификатор("d57859ca-1543-4c60-8427-5c2a41832831");
	Обработчик.Процедура = "МультиязычностьСервер.ОбновитьПредставленияПредопределенныхЭлементов";
	Обработчик.Комментарий = НСтр("ru = 'Обновление наименований предопределенных элементов.
		|До завершения обработки наименования этих элементов в ряде случаев будет отображаться некорректно.'");
	Обработчик.РежимВыполнения = "Отложенно";
	Обработчик.ОчередьОтложеннойОбработки = 2;
	Обработчик.ПроцедураЗаполненияДанныхОбновления = "МультиязычностьСервер.ЗарегистрироватьПредопределенныеЭлементыДляОбновления";
	Обработчик.ЧитаемыеОбъекты      = ОбъектыСПредопределеннымиЭлементами;
	Обработчик.ИзменяемыеОбъекты    = ОбъектыСПредопределеннымиЭлементами;
	Обработчик.ПроцедураПроверки    = "ОбновлениеИнформационнойБазы.ДанныеОбновленыНаНовуюВерсиюПрограммы";
	Обработчик.БлокируемыеОбъекты   = ОбъектыСПредопределеннымиЭлементами;
	
	Если ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.КонтактнаяИнформация") Тогда
		Обработчик.ПриоритетыВыполнения = ОбновлениеИнформационнойБазы.ПриоритетыВыполненияОбработчика();
		Приоритет = Обработчик.ПриоритетыВыполнения.Добавить();
		Приоритет.Процедура = "Справочники.СтраныМира.ОбработатьДанныеДляПереходаНаНовуюВерсию";
		Приоритет.Порядок = "Любой";
	КонецЕсли;
	
	Возврат Обработчик;
	
КонецФункции

#КонецОбласти

#Область СлужебныйПрограммныйИнтерфейс

Процедура ИзменениеТекстаЗапросаСпискаДляТекущегоЯзыка(ЭтотОбъект, ИмяСписка = "Список") Экспорт
	
	СуффиксЯзыка = СуффиксТекущегоЯзыка();
	
	Если ПустаяСтрока(СуффиксЯзыка) Тогда
		Возврат;
	КонецЕсли;
	
	Список = ЭтотОбъект[ИмяСписка];
	Если ПустаяСтрока(Список.ТекстЗапроса) Тогда
		Возврат;
	КонецЕсли;
	
	ДобавляемыеРеквизиты = Новый Массив;
	НаборЧастейПутиОбъектаМетаданных = СтрРазделить(ЭтотОбъект.ИмяФормы, ".");
	ИмяОбъектаМетаданных = НаборЧастейПутиОбъектаМетаданных[0] + "." + НаборЧастейПутиОбъектаМетаданных[1];
	ОбъектМетаданных = Метаданные.НайтиПоПолномуИмени(ИмяОбъектаМетаданных);
	
	ЛокализуемыеРеквизиты = ЛокализуемыеРеквизитыОбъектаДляТекущегоЯзыка(ОбъектМетаданных);
	РеквизитыДляДобавления = Новый Массив;
	
	ШаблонВыбора = "ВЫБОР
	|КОГДА ЕСТЬNULL(Подстрока(%1.%2, 1, 1),"" "") <> "" "" ТОГДА %1.%2
	|ИНАЧЕ %1.%3
	|КОНЕЦ";
	
	МодельЗапроса = Новый СхемаЗапроса;
	МодельЗапроса.УстановитьТекстЗапроса(Список.ТекстЗапроса);
	
	Для Каждого ПакетЗапроса Из МодельЗапроса.ПакетЗапросов Цикл
		Для Каждого ОператорЗапроса Из ПакетЗапроса.Операторы Цикл
			Для Каждого ИсточникЗапроса Из ОператорЗапроса.Источники Цикл
				Если СтрСравнить(ИсточникЗапроса.Источник.ИмяТаблицы, ИмяОбъектаМетаданных) = 0 Тогда
					
					Для каждого ОписаниеРеквизита Из ЛокализуемыеРеквизиты Цикл
						
						ИмяОсновногоРеквизита = Лев(ОписаниеРеквизита.Ключ, СтрДлина(ОписаниеРеквизита.Ключ) - 5);
						ПолноеИмя = ИсточникЗапроса.Источник.Псевдоним + "."+ ИмяОсновногоРеквизита;
						
						Для Индекс = 0 По ОператорЗапроса.ВыбираемыеПоля.Количество() - 1 Цикл
							
							ВыбираемоеПоле = ОператорЗапроса.ВыбираемыеПоля.Получить(Индекс);
							Псевдоним = ПакетЗапроса.Колонки[Индекс].Псевдоним + СуффиксЯзыка;
							Позиция = СтрНайти(ВыбираемоеПоле, ПолноеИмя);
							
							Если Позиция = 0 Тогда
								Продолжить;
							КонецЕсли;
							
							ТекстВыбораПоля = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(ШаблонВыбора,
							ИсточникЗапроса.Источник.Псевдоним, ОписаниеРеквизита.Ключ, ИмяОсновногоРеквизита);
							
							Если СтрСравнить(ВыбираемоеПоле, ПолноеИмя) = 0 Тогда
								
								ВыбираемоеПоле = СтрЗаменить(ВыбираемоеПоле, ПолноеИмя, ТекстВыбораПоля);
								
							Иначе
								
								ВыбираемоеПоле = СтрЗаменить(ВыбираемоеПоле, ПолноеИмя + Символы.ПС,
									ТекстВыбораПоля + Символы.ПС);
								ВыбираемоеПоле = СтрЗаменить(ВыбираемоеПоле, ПолноеИмя + " ",
									ТекстВыбораПоля + " " );
								ВыбираемоеПоле = СтрЗаменить(ВыбираемоеПоле, ПолноеИмя + ")",
									ТекстВыбораПоля + ")" );
								
							КонецЕсли;
							
							ОператорЗапроса.ВыбираемыеПоля.Установить(Индекс, Новый ВыражениеСхемыЗапроса(ВыбираемоеПоле));
						КонецЦикла;
						
					КонецЦикла;
					
				КонецЕсли;
			КонецЦикла;
		КонецЦикла;
	КонецЦикла;
	
	Список.ТекстЗапроса = МодельЗапроса.ПолучитьТекстЗапроса();
	
КонецПроцедуры

Функция СуффиксТекущегоЯзыка() Экспорт
	
	Возврат СуффиксЯзыка(ТекущийЯзык().КодЯзыка);
	
КонецФункции

Функция ИмяЛокализуемогоРеквизита(ИмяРеквизита, КодЯзыка) Экспорт
	
	Возврат ИмяРеквизита + "_" + КодЯзыка;
	
КонецФункции

// Возвращает метаданные по коду языка конфигурации.
//
// Параметры:
//   КодЯзыка - Строка - код языка, например "en" (как задано в свойстве КодЯзыка метаданных ОбъектМетаданных: Язык).
//
// Возвращаемое значение:
//   ОбъектМетаданных: Язык - если найден по переданному коду языка, иначе Неопределено.
//   
Функция ЯзыкПоКоду(Знач КодЯзыка) Экспорт
	Для каждого Язык Из Метаданные.Языки Цикл
		Если Язык.КодЯзыка = КодЯзыка Тогда
			Возврат Язык;
		КонецЕсли;
	КонецЦикла;
	Возврат Неопределено;
КонецФункции	

Процедура ЗарегистрироватьПредопределенныеЭлементыДляОбновления(Параметры) Экспорт
	СтандартныеПодсистемыСервер.ЗарегистрироватьПредопределенныеЭлементыДляОбновления(Параметры);
КонецПроцедуры

Процедура ОбновитьПредставленияПредопределенныхЭлементов(Параметры) Экспорт
	СтандартныеПодсистемыСервер.ОбновитьПредставленияПредопределенныхЭлементов(Параметры);
КонецПроцедуры

Функция ИспользуетсяПервыйДополнительныйЯзык() Экспорт
	
	Возврат Константы.ИспользоватьДополнительныйЯзык1.Получить() = Истина;
	
КонецФункции

Функция ИспользуетсяВторойДополнительныйЯзык() Экспорт
	
	Возврат Константы.ИспользоватьДополнительныйЯзык2.Получить() = Истина;
	
КонецФункции

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

// Код основного языка информационной базы
// 
// Возвращаемое значение:
//  Строка - код языка. Например, "ru".
//
Функция КодЯзыкаИнформационнойБазы()
	
	Если ЗначениеЗаполнено(Константы.ОсновнойЯзык.Получить()) Тогда
		Возврат Константы.ОсновнойЯзык.Получить();
	КонецЕсли;
	
	Возврат Метаданные.ОсновнойЯзык.КодЯзыка;
	
КонецФункции

Функция ОпределитьТипФормы(ИмяФормы) Экспорт
	
	Результат = "";
	
	ЧастиИмениФормы = СтрРазделить(ВРег(ИмяФормы), ".");
	ОсновнаяФормаСписка = ОсновнаяФормаСписка(ЧастиИмениФормы);
	ОсновнаяФормаВыбора = ОсновнаяФормаДляВыбора(ЧастиИмениФормы);
	
	НайденнаяФорма = Метаданные.НайтиПоПолномуИмени(ИмяФормы);
	
	Если ОсновнаяФормаСписка = НайденнаяФорма  Тогда
		Результат =  "ОсновнаяФормаСписка";
	ИначеЕсли ОсновнаяФормаВыбора  = НайденнаяФорма Тогда
		Результат = "ОсновнаяФормаВыбора";
	КонецЕсли;
	
	Возврат Результат;
	
КонецФункции

// См. ОбщегоНазначенияПереопределяемый.ПриДобавленииОбработчиковУстановкиПараметровСеанса.
Процедура УстановкаПараметровСеанса(Знач ИменаПараметровСеанса, УстановленныеПараметры) Экспорт
	
	Если ИменаПараметровСеанса = Неопределено
	 Или ИменаПараметровСеанса.Найти("ОсновнойЯзык") <> Неопределено Тогда
		
		ПараметрыСеанса.ОсновнойЯзык = КодЯзыкаИнформационнойБазы();
		УстановленныеПараметры.Добавить("ОсновнойЯзык");
	КонецЕсли;
	
КонецПроцедуры

Функция МультиязычныеСтрокиВРеквизитах(ОбъектМетаданных) Экспорт
	Возврат ОбъектМетаданных.ТабличныеЧасти.Найти("Представления") = Неопределено;
КонецФункции

Функция КодПервогоДополнительногоЯзыкаИнформационнойБазы() Экспорт
	
	Если Не ИспользуетсяПервыйДополнительныйЯзык() Тогда
		Возврат "";
	КонецЕсли;
	
	Возврат Константы.ДополнительныйЯзык1.Получить();
	
КонецФункции

Функция КодВторогоДополнительногоЯзыкаИнформационнойБазы() Экспорт
	
	Если Не ИспользуетсяВторойДополнительныйЯзык() Тогда
		Возврат "";
	КонецЕсли;
	
	Возврат Константы.ДополнительныйЯзык2.Получить();
	
КонецФункции

Функция ЛокализуемыеРеквизитыОбъектаДляТекущегоЯзыка(ОбъектМетаданных, Язык = Неопределено)
	
	СписокРеквизитов = Новый Соответствие;
	
	ПрефиксЯзыка = СуффиксТекущегоЯзыка();
	
	СписокРеквизитовОбъекта = Новый Соответствие;
	
	Для Каждого Реквизит Из ОбъектМетаданных.Реквизиты Цикл
		СписокРеквизитовОбъекта.Вставить(Реквизит.Имя, Реквизит);
	КонецЦикла;
	
	Для Каждого Реквизит Из ОбъектМетаданных.СтандартныеРеквизиты Цикл
		СписокРеквизитовОбъекта.Вставить(Реквизит.Имя, Реквизит);
	КонецЦикла;
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ ПЕРВЫЕ 0
		|	*
		|ИЗ
		|	" + ОбъектМетаданных.ПолноеИмя();
	
	РезультатЗапроса = Запрос.Выполнить();
	
	СписокРеквизитов = Новый Соответствие;
	Для каждого Колонка Из РезультатЗапроса.Колонки Цикл
		Если СтрЗаканчиваетсяНа(Колонка.Имя, ПрефиксЯзыка) Тогда
			Реквизит = СписокРеквизитовОбъекта.Получить(Колонка.Имя);
			Если Реквизит = Неопределено Тогда
				Реквизит = Метаданные.ОбщиеРеквизиты.Найти(Колонка.Имя);
			КонецЕсли;
			СписокРеквизитов.Вставить(Колонка.Имя, Реквизит);
			
		КонецЕсли;
	КонецЦикла;
	
	Возврат СписокРеквизитов;
	
КонецФункции

Функция НаименованияЛокализуемыхРеквизитыОбъекта(ОбъектМетаданных, Префикс = "") Экспорт
	
	СписокРеквизитовОбъекта = Новый Соответствие;
	Если МультиязычныеСтрокиВРеквизитах(ОбъектМетаданных) Тогда
	
		ДлинаСуффиксаЯзыка = СтрДлина("Язык1");
		
		Запрос = Новый Запрос;
		Запрос.Текст = 
			"ВЫБРАТЬ РАЗРЕШЕННЫЕ ПЕРВЫЕ 0
			|	*
			|ИЗ
			|	" + ОбъектМетаданных.ПолноеИмя();
		
		РезультатЗапроса = Запрос.Выполнить();
		
		СписокРеквизитов = Новый Соответствие;
		Для каждого Колонка Из РезультатЗапроса.Колонки Цикл
			Если СтрЗаканчиваетсяНа(Колонка.Имя, "Язык1") Или СтрЗаканчиваетсяНа(Колонка.Имя, "Язык2") Тогда
				СписокРеквизитовОбъекта.Вставить(Префикс + Лев(Колонка.Имя, СтрДлина(Колонка.Имя) - ДлинаСуффиксаЯзыка), Истина);
			КонецЕсли;
		КонецЦикла;
	Иначе
		
		Для каждого Реквизит Из ОбъектМетаданных.ТабличныеЧасти.Представления.Реквизиты Цикл
			Если СтрСравнить(Реквизит.Имя, "КодЯзыка") = 0 Тогда
				Продолжить;
			КонецЕсли;
			СписокРеквизитовОбъекта.Вставить(Префикс + Реквизит.Имя, Истина);
		КонецЦикла;
		
	КонецЕсли;
	
	Возврат СписокРеквизитовОбъекта;
	
КонецФункции

Функция ОсновнаяФормаСписка(ЧастиИмениФормы)
	
	Если ЧастиИмениФормы[0]= "СПРАВОЧНИК"
		Или ЧастиИмениФормы[0] = "ДОКУМЕНТ"
		Или ЧастиИмениФормы[0] = "ПЕРЕЧИСЛЕНИЕ"
		Или ЧастиИмениФормы[0] = "ПЛАНВИДОВХАРАКТЕРИСТИК"
		Или ЧастиИмениФормы[0] = "ПЛАНСЧЕТОВ"
		Или ЧастиИмениФормы[0] = "ПЛАНВИДОВРАСЧЕТА"
		Или ЧастиИмениФормы[0] = "БИЗНЕСПРОЦЕСС"
		Или ЧастиИмениФормы[0] = "ЗАДАЧА"
		Или ЧастиИмениФормы[0] = "ЗАДАЧА"
		Или ЧастиИмениФормы[0] = "РЕГИСТРЫБУХГАЛТЕРИИ"
		Или ЧастиИмениФормы[0] = "РЕГИСТРЫНАКОПЛЕНИЯ"
		Или ЧастиИмениФормы[0] = "РЕГИСТРЫРАСЧЕТА"
		Или ЧастиИмениФормы[0] = "РЕГИСТРЫСВЕДЕНИЙ"
		Или ЧастиИмениФормы[0] = "ПЛАНОБМЕНА" Тогда
			Возврат Метаданные.НайтиПоПолномуИмени(ЧастиИмениФормы[0] + "." + ЧастиИмениФормы[1]).ОсновнаяФормаСписка;
	КонецЕсли;
	
	Возврат Неопределено;
	
КонецФункции

Функция ОсновнаяФормаДляВыбора(ЧастиИмениФормы)
	
	Если ЧастиИмениФормы[0]= "СПРАВОЧНИК"
		Или ЧастиИмениФормы[0] = "ДОКУМЕНТ"
		Или ЧастиИмениФормы[0] = "ПЕРЕЧИСЛЕНИЕ"
		Или ЧастиИмениФормы[0] = "ПЛАНВИДОВХАРАКТЕРИСТИК"
		Или ЧастиИмениФормы[0] = "ПЛАНСЧЕТОВ"
		Или ЧастиИмениФормы[0] = "БИЗНЕСПРОЦЕСС"
		Или ЧастиИмениФормы[0] = "ЗАДАЧА"
		Или ЧастиИмениФормы[0] = "ЗАДАЧА"
		Или ЧастиИмениФормы[0] = "ПЛАНОБМЕНА" Тогда
			Возврат Метаданные.НайтиПоПолномуИмени(ЧастиИмениФормы[0] + "." + ЧастиИмениФормы[1]).ОсновнаяФормаДляВыбора;
	КонецЕсли;
	
	Возврат Неопределено;
	
КонецФункции

Процедура ПерезаполнитьМультиязычныеСтрокиВОбъектах(Параметры, Адрес) Экспорт
	СтандартныеПодсистемыСервер.ЗаполнитьЭлементыНачальнымиДанными(Истина);
КонецПроцедуры

Функция ЭтоОсновнойЯзык() Экспорт
	
	Возврат СтрСравнить(ОбщегоНазначения.КодОсновногоЯзыка(), ТекущийЯзык().КодЯзыка) = 0;
	
КонецФункции

// По коду языка возвращает суффикс "Язык1" или "Язык2".
//
Функция СуффиксЯзыка(Язык)
	
	Если Язык = Константы.ДополнительныйЯзык1.Получить() Тогда
		Возврат "Язык1";
	КонецЕсли;
	
	Если Язык = Константы.ДополнительныйЯзык2.Получить() Тогда
		Возврат "Язык2";
	КонецЕсли;
	
	Возврат "";
	
КонецФункции

Функция ОбъектыСПредопределеннымиЭлементамиСтрокой()
	
	НастройкиПодсистемы = ОбновлениеИнформационнойБазыСлужебный.НастройкиПодсистемы();
	ОбъектыСНачальнымЗаполнением = НастройкиПодсистемы.ОбъектыСНачальнымЗаполнением;
	Список = Новый Массив;
	Для каждого ОбъектСПредопределеннымиЭлементами Из ОбъектыСНачальнымЗаполнением Цикл
		Список.Добавить(ОбъектСПредопределеннымиЭлементами.ПолноеИмя());
	КонецЦикла;
	
	Возврат СтрСоединить(Список, ",");
	
КонецФункции

#КонецОбласти