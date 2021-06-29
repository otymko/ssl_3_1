﻿///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2021, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область ПрограммныйИнтерфейс

// Открывает форму ввода параметров администрирования информационной базы и/или кластера.
//
// Параметры:
//  ОписаниеОповещенияОЗакрытии - ОписаниеОповещения - обработчик, который будет вызван после ввода параметров
//	                                                   администрирования.
//  ЗапрашиватьПараметрыАдминистрированияИБ - Булево - признак необходимости ввода параметров администрирования
//	                                                   информационной базы.
//  ЗапрашиватьПараметрыАдминистрированияКластера - Булево - признак необходимости ввода параметров администрирования
//	                                                         кластера.
//  ПараметрыАдминистрирования - см. СтандартныеПодсистемыСервер.ПараметрыАдминистрирования.
//  Заголовок - Строка - заголовок формы, описывающий для чего запрашиваются параметры администрирования.
//  ПоясняющаяНадпись - Строка - пояснение для выполняемого действия, в контексте которого запрашиваются параметры.
//
Процедура ПоказатьПараметрыАдминистрирования(ОписаниеОповещенияОЗакрытии, ЗапрашиватьПараметрыАдминистрированияИБ,
	ЗапрашиватьПараметрыАдминистрированияКластера, ПараметрыАдминистрирования = Неопределено,
	Заголовок = "", ПоясняющаяНадпись = "") Экспорт
	
	ПараметрыФормы = Новый Структура;
	ПараметрыФормы.Вставить("ЗапрашиватьПараметрыАдминистрированияИБ", ЗапрашиватьПараметрыАдминистрированияИБ);
	ПараметрыФормы.Вставить("ЗапрашиватьПараметрыАдминистрированияКластера", ЗапрашиватьПараметрыАдминистрированияКластера);
	ПараметрыФормы.Вставить("ПараметрыАдминистрирования", ПараметрыАдминистрирования);
	ПараметрыФормы.Вставить("Заголовок", Заголовок);
	ПараметрыФормы.Вставить("ПоясняющаяНадпись", ПоясняющаяНадпись);
	
	ОткрытьФорму("ОбщаяФорма.ПараметрыАдминистрированияПрограммы", ПараметрыФормы,,,,,ОписаниеОповещенияОЗакрытии);
	
КонецПроцедуры

// Устанавливает и отключает режим завершения работы пользователей в программе.
// При завершении работы, до наступления момента блокировки, всем активным пользователям
// будет выводиться уведомление о планируемом завершении работы программы и рекомендацией
// сохранить все свои данные.
// Текущий сеанс завершается последним.
//
// Параметры:
//  ЗавершитьРаботу - Булево.
//
Процедура УстановитьРежимЗавершенияРаботыПользователей(Знач ЗавершитьРаботу) Экспорт
	
	УстановитьПризнакРаботаПользователейЗавершается(ЗавершитьРаботу);
	Если ЗавершитьРаботу Тогда
		// Поскольку блокировка еще не установлена, то при входе в систему
		// для данного пользователя был подключен обработчик ожидания завершения работы.
		// Отключаем его. Так как для этого пользователя подключается специализированный обработчик ожидания
		// "ЗавершитьРаботуПользователей", который ориентирован на то, что данный пользователь
		// должен быть отключен последним.
		
		ОтключитьОбработчикОжидания("КонтрольРежимаЗавершенияРаботыПользователей");
		ПодключитьОбработчикОжидания("ЗавершитьРаботуПользователей", 60);
		ЗавершитьРаботуПользователей();
	Иначе
		ОтключитьОбработчикОжидания("ЗавершитьРаботуПользователей");
		ПодключитьОбработчикОжидания("КонтрольРежимаЗавершенияРаботыПользователей", 60);
	КонецЕсли;
	
КонецПроцедуры

// Позволяет отметить необходимость завершения работы сеанса, включившего блокировку работы
// пользователей в программе.
//
// Параметры:
//   Значение - Булево - Истина, если если текущий сеанс завершать не требуется.
//
Процедура УстановитьПризнакЗавершитьВсеСеансыКромеТекущего(Значение) Экспорт
	
	ИмяПараметра = "СтандартныеПодсистемы.ПараметрыЗавершенияРаботыПользователей";
	Если ПараметрыПриложения[ИмяПараметра] = Неопределено Тогда
		ПараметрыПриложения.Вставить(ИмяПараметра, Новый Структура);
	КонецЕсли;
	
	ПараметрыПриложения["СтандартныеПодсистемы.ПараметрыЗавершенияРаботыПользователей"].Вставить("ЗавершитьВсеСеансыКромеТекущего", Значение);
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныйПрограммныйИнтерфейс

// Завершает работу (последнего) сеанса администратора, который инициировал завершение работы пользователей.
//
Процедура ЗавершитьРаботуЭтогоСеанса(ВыводитьВопрос = Истина) Экспорт
	
	УстановитьПризнакРаботаПользователейЗавершается(Ложь);
	ОтключитьОбработчикОжидания("ЗавершитьРаботуПользователей");
	
	Если ЗавершитьВсеСеансыКромеТекущего() Тогда
		Возврат;
	КонецЕсли;
	
	Если Не ВыводитьВопрос Тогда 
		ЗавершитьРаботуСистемы(Ложь);
		Возврат;
	КонецЕсли;
	
	Оповещение = Новый ОписаниеОповещения("ЗавершитьРаботуЭтогоСеансаЗавершение", ЭтотОбъект);
	ТекстСообщения = НСтр("ru = 'Работа пользователей с программой запрещена. Завершить работу этого сеанса?'");
	Заголовок = НСтр("ru = 'Завершение работы текущего сеанса'");
	ПоказатьВопрос(Оповещение, ТекстСообщения, РежимДиалогаВопрос.ДаНет, 60, КодВозвратаДиалога.Да, Заголовок, КодВозвратаДиалога.Да);
	
КонецПроцедуры

// Устанавливает значение переменной РаботаПользователейЗавершается в значение Значение.
//
// Параметры:
//   Значение - Булево - устанавливаемое значение.
//
Процедура УстановитьПризнакРаботаПользователейЗавершается(Значение) Экспорт
	
	ИмяПараметра = "СтандартныеПодсистемы.ПараметрыЗавершенияРаботыПользователей";
	Если ПараметрыПриложения[ИмяПараметра] = Неопределено Тогда
		ПараметрыПриложения.Вставить(ИмяПараметра, Новый Структура);
	КонецЕсли;
	
	ПараметрыПриложения["СтандартныеПодсистемы.ПараметрыЗавершенияРаботыПользователей"].Вставить("РаботаПользователейЗавершается", Значение);
	
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// Обработчики событий подсистем конфигурации.

// Вызывается при интерактивном начале работы пользователя с областью данных.
//
// Параметры:
//  ПараметрыЗапуска - Массив - массив строк разделенных символом ";" в параметре запуска,
//                     переданным в конфигурацию с помощью ключа командной строки /C.
//  Отказ            - Булево - возвращаемое значение. Если установить Истина,
//                     обработка события ПриНачалеРаботыСистемы будет прервана.
//
Процедура ПриОбработкеПараметровЗапуска(ПараметрыЗапуска, Отказ) Экспорт
	
	Отказ = Отказ Или ОбработатьПараметрыЗапуска(ПараметрыЗапуска);
	
КонецПроцедуры

// См. ОбщегоНазначенияКлиентПереопределяемый.ПередНачаломРаботыСистемы.
Процедура ПередНачаломРаботыСистемы(Параметры) Экспорт
	
	ПараметрыКлиента = СтандартныеПодсистемыКлиент.ПараметрыРаботыКлиентаПриЗапуске();
	
	Если Не ПараметрыКлиента.Свойство("СеансыОбластиДанныхЗаблокированы") Тогда
		Возврат;
	КонецЕсли;
	
	Параметры.ИнтерактивнаяОбработка = Новый ОписаниеОповещения(
		"ИнтерактивнаяОбработкаПередНачаломРаботыСистемы", ЭтотОбъект);
	
КонецПроцедуры

// См. ОбщегоНазначенияКлиентПереопределяемый.ПослеНачалаРаботыСистемы.
Процедура ПослеНачалаРаботыСистемы() Экспорт
	
	ПараметрыРаботы = СтандартныеПодсистемыКлиент.ПараметрыРаботыКлиентаПриЗапуске();
	Если НЕ ПараметрыРаботы.ДоступноИспользованиеРазделенныхДанных Тогда
		Возврат;
	КонецЕсли;
	
	Если ПолучитьСкоростьКлиентскогоСоединения() <> СкоростьКлиентскогоСоединения.Обычная Тогда
		Возврат;
	КонецЕсли;
	
	РежимБлокировки = ПараметрыРаботы.ПараметрыБлокировкиСеансов;
	ТекущееВремя = РежимБлокировки.ТекущаяДатаСеанса;
	Если РежимБлокировки.Установлена 
		 И (НЕ ЗначениеЗаполнено(РежимБлокировки.Начало) ИЛИ ТекущееВремя >= РежимБлокировки.Начало) 
		 И (НЕ ЗначениеЗаполнено(РежимБлокировки.Конец) ИЛИ ТекущееВремя <= РежимБлокировки.Конец) Тогда
		// Если пользователь зашел в базу, в которой установлена режим блокировки, значит использовался ключ /UC.
		// Завершать работу такого пользователя не следует.
		Возврат;
	КонецЕсли;
	
	Если СтрНайти(ВРег(ПараметрЗапуска), ВРег("ЗавершитьРаботуПользователей")) > 0 Тогда
		Возврат;
	КонецЕсли;
	
	ПодключитьОбработчикОжидания("КонтрольРежимаЗавершенияРаботыПользователей", 60);
	
КонецПроцедуры

// Параметры:
//  Отказ - см. ОбщегоНазначенияКлиентПереопределяемый.ПередЗавершениемРаботыСистемы.Отказ
//  Предупреждения - см. ОбщегоНазначенияКлиентПереопределяемый.ПередЗавершениемРаботыСистемы.Предупреждения
//
Процедура ПередЗавершениемРаботыСистемы(Отказ, Предупреждения) Экспорт
	
	Если РаботаПользователейЗавершается() Тогда
		ПараметрыПредупреждения = СтандартныеПодсистемыКлиент.ПредупреждениеПриЗавершенииРаботы();
		ПараметрыПредупреждения.ТекстГиперссылки = НСтр("ru = 'Блокировка работы пользователей'");
		ПараметрыПредупреждения.ТекстПредупреждения = НСтр("ru = 'Из текущего сеанса выполняется завершение работы пользователей'");
		ПараметрыПредупреждения.ВывестиОдноПредупреждение = Истина;
		
		Форма = "Обработка.БлокировкаРаботыПользователей.Форма.БлокировкаСоединенийСИнформационнойБазой";
		
		ДействиеПриНажатииГиперссылки = ПараметрыПредупреждения.ДействиеПриНажатииГиперссылки;
		ДействиеПриНажатииГиперссылки.Форма = Форма;
		ДействиеПриНажатииГиперссылки.ПрикладнаяФормаПредупреждения = Форма;
		
		Предупреждения.Добавить(ПараметрыПредупреждения);
	КонецЕсли;
	
КонецПроцедуры

// Вызывается при неудачной попытке установить монопольный режим в файловой базе.
//
// Параметры:
//  Оповещение - ОписаниеОповещения - описывает, куда надо передать управление после закрытия формы.
//
Процедура ПриОткрытииФормыОшибкиУстановкиМонопольногоРежима(Оповещение = Неопределено, ПараметрыФормы = Неопределено) Экспорт
	
	ОткрытьФорму("Обработка.БлокировкаРаботыПользователей.Форма.ОшибкаУстановкиМонопольногоРежима", ПараметрыФормы,
		, , , , Оповещение);
	
КонецПроцедуры

// Открывает форму блокировки работы пользователей.
//
Процедура ПриОткрытииФормыБлокировкиРаботыПользователей(Оповещение = Неопределено, ПараметрыФормы = Неопределено) Экспорт
	
	ОткрытьФорму("Обработка.БлокировкаРаботыПользователей.Форма.БлокировкаСоединенийСИнформационнойБазой", ПараметрыФормы,
		, , , , Оповещение);
	
КонецПроцедуры

// Переопределяет стандартное предупреждение открытием произвольной формы активных пользователей.
//
// Параметры:
//  ИмяФормы - Строка - возвращаемое значение.
//
Процедура ПриОпределенииФормыАктивныхПользователей(ИмяФормы) Экспорт
	
	ИмяФормы = "Обработка.АктивныеПользователи.Форма.АктивныеПользователи";
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

///////////////////////////////////////////////////////////////////////////////
// Обработчики событий подсистемы БазоваяФункциональность.

Функция РаботаПользователейЗавершается() Экспорт
	
	ПараметрыЗавершенияРаботыПользователей = ПараметрыПриложения["СтандартныеПодсистемы.ПараметрыЗавершенияРаботыПользователей"];
	
	Возврат ТипЗнч(ПараметрыЗавершенияРаботыПользователей) = Тип("Структура")
		И ПараметрыЗавершенияРаботыПользователей.Свойство("РаботаПользователейЗавершается")
		И ПараметрыЗавершенияРаботыПользователей.РаботаПользователейЗавершается;
	
КонецФункции

Функция ЗавершитьВсеСеансыКромеТекущего()
	
	ПараметрыЗавершенияРаботыПользователей = ПараметрыПриложения["СтандартныеПодсистемы.ПараметрыЗавершенияРаботыПользователей"];
	
	Возврат ТипЗнч(ПараметрыЗавершенияРаботыПользователей) = Тип("Структура")
		И ПараметрыЗавершенияРаботыПользователей.Свойство("ЗавершитьВсеСеансыКромеТекущего")
		И ПараметрыЗавершенияРаботыПользователей.ЗавершитьВсеСеансыКромеТекущего;
	
КонецФункции

Функция СохраненныеПараметрыАдминистрирования() Экспорт
	
	ПараметрыЗавершенияРаботыПользователей = ПараметрыПриложения["СтандартныеПодсистемы.ПараметрыЗавершенияРаботыПользователей"];
	ПараметрыАдминистрирования = Неопределено;
	
	Если ТипЗнч(ПараметрыЗавершенияРаботыПользователей) = Тип("Структура")
		И ПараметрыЗавершенияРаботыПользователей.Свойство("ПараметрыАдминистрирования") Тогда
		
		ПараметрыАдминистрирования = ПараметрыЗавершенияРаботыПользователей.ПараметрыАдминистрирования;
		
	КонецЕсли;
		
	Возврат ПараметрыАдминистрирования;
	
КонецФункции

Процедура СохранитьПараметрыАдминистрирования(Значение) Экспорт
	
	ИмяПараметра = "СтандартныеПодсистемы.ПараметрыЗавершенияРаботыПользователей";
	Если ПараметрыПриложения[ИмяПараметра] = Неопределено Тогда
		ПараметрыПриложения.Вставить(ИмяПараметра, Новый Структура);
	КонецЕсли;
	
	ПараметрыПриложения["СтандартныеПодсистемы.ПараметрыЗавершенияРаботыПользователей"].Вставить("ПараметрыАдминистрирования", Значение);

КонецПроцедуры

Процедура ЗаполнитьПараметрыАдминистрированияКластера(ПараметрыЗапуска)
	
	ПараметрыАдминистрирования = СоединенияИБВызовСервера.ПараметрыАдминистрирования();
	КоличествоПараметров = ПараметрыЗапуска.Количество();
	
	Если КоличествоПараметров > 1 Тогда
		ПараметрыАдминистрирования.ИмяАдминистратораКластера = ПараметрыЗапуска[1];
	КонецЕсли;
	
	Если КоличествоПараметров > 2 Тогда
		ПараметрыАдминистрирования.ПарольАдминистратораКластера = ПараметрыЗапуска[2];
	КонецЕсли;
	
	СохранитьПараметрыАдминистрирования(ПараметрыАдминистрирования);
	
КонецПроцедуры

///////////////////////////////////////////////////////////////////////////////
// Обработчики оповещений.

// Предлагает снять блокировку и войти или прекратить работу системы.
Процедура ИнтерактивнаяОбработкаПередНачаломРаботыСистемы(Параметры, Контекст) Экспорт
	
	ПараметрыКлиента = СтандартныеПодсистемыКлиент.ПараметрыРаботыКлиентаПриЗапуске();
	
	ТекстВопроса   = ПараметрыКлиента.ПредложениеВойти;
	ТекстСообщения = ПараметрыКлиента.СеансыОбластиДанныхЗаблокированы;
	
	Если Не ПустаяСтрока(ТекстВопроса) Тогда
		Кнопки = Новый СписокЗначений();
		Кнопки.Добавить(КодВозвратаДиалога.Да, НСтр("ru = 'Войти'"));
		Если ПараметрыКлиента.ВозможноСнятьБлокировку Тогда
			Кнопки.Добавить(КодВозвратаДиалога.Нет, НСтр("ru = 'Снять блокировку и войти'"));
		КонецЕсли;
		Кнопки.Добавить(КодВозвратаДиалога.Отмена, НСтр("ru = 'Отмена'"));
		
		ОбработкаОтвета = Новый ОписаниеОповещения(
			"ПослеОтветаНаВопросВойтиИлиСнятьБлокировку", ЭтотОбъект, Параметры);
		
		ПоказатьВопрос(ОбработкаОтвета, ТекстВопроса, Кнопки, 15,
			КодВозвратаДиалога.Отмена,, КодВозвратаДиалога.Отмена);
		Возврат;
	Иначе
		Параметры.Отказ = Истина;
		ПоказатьПредупреждение(
			СтандартныеПодсистемыКлиент.ОповещениеБезРезультата(Параметры.ОбработкаПродолжения),
			ТекстСообщения, 15);
	КонецЕсли;
	
КонецПроцедуры

// Продолжение предыдущей процедуры.
Процедура ПослеОтветаНаВопросВойтиИлиСнятьБлокировку(Ответ, Параметры) Экспорт
	
	Если Ответ = КодВозвратаДиалога.Да Тогда // Входим в заблокированное приложение.
		
	ИначеЕсли Ответ = КодВозвратаДиалога.Нет Тогда // Снимаем блокировку и входим в приложение.
		СоединенияИБВызовСервера.УстановитьБлокировкуСеансовОбластиДанных(
			Новый Структура("Установлена", Ложь));
	Иначе
		Параметры.Отказ = Истина;
	КонецЕсли;
	
	ВыполнитьОбработкуОповещения(Параметры.ОбработкаПродолжения);
	
КонецПроцедуры

Процедура ПоказатьПредупреждениеПриЗавершенииРаботы(ТекстСообщения) Экспорт
	
	ИмяПараметра = "СтандартныеПодсистемы.ПоказаноПредупреждениеПередЗавершениемРаботы";
	Если ПараметрыПриложения[ИмяПараметра] <> Истина Тогда
		ПоказатьОповещениеПользователя(НСтр("ru = 'Работа программы будет завершена'"),, ТекстСообщения,, 
			СтатусОповещенияПользователя.Важное);
		ПараметрыПриложения.Вставить(ИмяПараметра, Истина);
	КонецЕсли;	
	ПоказатьПредупреждение(, ТекстСообщения, 30);
	
КонецПроцедуры

Процедура ЗадатьВопросПриЗавершенииРаботы(ТекстСообщения) Экспорт
	
	ИмяПараметра = "СтандартныеПодсистемы.ПоказаноПредупреждениеПередЗавершениемРаботы";
	Если ПараметрыПриложения[ИмяПараметра] <> Истина Тогда
		ПоказатьОповещениеПользователя(НСтр("ru = 'Работа программы будет завершена'"),, ТекстСообщения,, СтатусОповещенияПользователя.Важное);
		ПараметрыПриложения.Вставить("СтандартныеПодсистемы.ПоказаноПредупреждениеПередЗавершениемРаботы", Истина);
	КонецЕсли;	
		
	ТекстВопроса = НСтр("ru = '%1
		|Завершить работу?'");
	ТекстВопроса = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(ТекстВопроса, ТекстСообщения);
	ОписаниеОповещения = Новый ОписаниеОповещения("ЗадатьВопросПриЗавершенииРаботыЗавершение", ЭтотОбъект);
	ПоказатьВопрос(ОписаниеОповещения, ТекстВопроса, РежимДиалогаВопрос.ДаНет, 30, КодВозвратаДиалога.Да);
	
КонецПроцедуры

Процедура ЗадатьВопросПриЗавершенииРаботыЗавершение(Ответ, ДополнительныеПараметры) Экспорт
	
	Если Ответ = КодВозвратаДиалога.Да Тогда
		СтандартныеПодсистемыКлиент.ПропуститьПредупреждениеПередЗавершениемРаботыСистемы();
		ЗавершитьРаботуСистемы(Истина, Ложь);
	КонецЕсли;
	
КонецПроцедуры

Процедура ЗавершитьРаботуЭтогоСеансаЗавершение(Ответ, Параметры) Экспорт
	
	Если Ответ <> КодВозвратаДиалога.Нет Тогда
		СтандартныеПодсистемыКлиент.ПропуститьПредупреждениеПередЗавершениемРаботыСистемы();
		ЗавершитьРаботуСистемы(Ложь);
	КонецЕсли;
	
КонецПроцедуры	

// Обработать параметры запуска, связанные с завершением и разрешением соединений ИБ.
//
// Параметры:
//  ЗначениеПараметраЗапуска  - Строка - главный параметр запуска.
//  ПараметрыЗапуска          - Массив - дополнительные параметры запуска, разделенные
//                                       символом ";".
//
// Возвращаемое значение:
//   Булево   - Истина, если требуется прекратить выполнение запуска системы.
//
Функция ОбработатьПараметрыЗапуска(Знач ПараметрыЗапуска)

	ПараметрыРаботы = СтандартныеПодсистемыКлиент.ПараметрыРаботыКлиентаПриЗапуске();
	Если НЕ ПараметрыРаботы.ДоступноИспользованиеРазделенныхДанных Тогда
		Возврат Ложь;
	КонецЕсли;
	
	// Обработка параметров запуска программы - 
	// ЗапретитьРаботуПользователей и РазрешитьРаботуПользователей.
	Если КлючСодержитсяВПараметрахЗапуска(ПараметрыЗапуска, "РазрешитьРаботуПользователей") Тогда
		
		Если НЕ СоединенияИБВызовСервера.РазрешитьРаботуПользователей() Тогда
			ТекстСообщения = НСтр("ru = 'Параметр запуска РазрешитьРаботуПользователей не отработан. Нет прав на администрирование информационной базы.'");
			ПоказатьПредупреждение(,ТекстСообщения);
			Возврат Ложь;
		КонецЕсли;
		
		ЖурналРегистрацииКлиент.ДобавитьСообщениеДляЖурналаРегистрации(СобытиеЖурналаРегистрации(),,
			НСтр("ru = 'Выполнен запуск с параметром ""РазрешитьРаботуПользователей"". Работа программы будет завершена.'"), ,Истина);
		ЗавершитьРаботуСистемы(Ложь);
		Возврат Истина;
		
	// Параметр может содержать две дополнительные части, разделенные символом ";" - 
	// имя и пароль администратора ИБ, от имени которого происходит подключение к кластеру серверов
	// в клиент-серверном варианте развертывания системы. Их необходимо передавать в случае, 
	// если текущий пользователь не является администратором ИБ.
	// См. использование в процедуре ЗавершитьРаботуПользователей().
	ИначеЕсли КлючСодержитсяВПараметрахЗапуска(ПараметрыЗапуска, "ЗавершитьРаботуПользователей") Тогда
		
		ДополнительныеПараметры = ДополнительныеПараметрыЗавершенияРаботыПользователей();
		
		БлокировкаУстановлена = СоединенияИБВызовСервера.УстановитьБлокировкуСоединений(
			ДополнительныеПараметры.ТекстСообщения,
			ДополнительныеПараметры.КодРазрешения,
			ДополнительныеПараметры.ОжиданиеНачалаБлокировкиМин,
			ДополнительныеПараметры.ДлительностьБлокировкиМин);
		
		Если НЕ БлокировкаУстановлена Тогда 
			ТекстСообщения = НСтр("ru = 'Параметр запуска ЗавершитьРаботуПользователей не отработан. Нет прав на администрирование информационной базы.'");
			ПоказатьПредупреждение(,ТекстСообщения);
			Возврат Ложь;
		КонецЕсли;
		
		ПараметрыЗапускаУточненные = ПараметрыЗапускаУточненные(ПараметрыЗапуска, ДополнительныеПараметры);
		
		// Если выполнен запуск с ключом, то нужно зачитать параметры администрирования кластера.
		ЗаполнитьПараметрыАдминистрированияКластера(ПараметрыЗапускаУточненные);
		
		ПодключитьОбработчикОжидания("ЗавершитьРаботуПользователей", 60);
		ЗавершитьРаботуПользователей();
		
		Возврат Ложь; // Продолжить запуск программы.
		
	КонецЕсли;
	Возврат Ложь;
	
КонецФункции

// Возвращает строковую константу для формирования сообщений журнала регистрации.
//
// Возвращаемое значение:
//   Строка - наименование события для журнала регистрации.
//
Функция СобытиеЖурналаРегистрации() Экспорт
	
	Возврат НСтр("ru = 'Завершение работы пользователей'", ОбщегоНазначенияКлиент.КодОсновногоЯзыка());
	
КонецФункции

#Область ДополнительныеПараметрыЗавершенияРаботыПользователей

// Извлекает параметры блокировки сеанса из параметра запуска.
//
// Возвращаемое значение:
//   Структура:
//     * ИмяАдминистратораКластера    - Строка - имя администратор кластера серверов 1С.
//     * ПарольАдминистратораКластера - Строка - пароль администратор кластера серверов 1С.
//     * ТекстСообщения               - Строка - текст, который будет частью сообщения об ошибке
//                                               при попытке установки соединения с заблокированной
//                                               информационной базой.
//     * КодРазрешения                - Строка - строка, которая должна быть добавлена к параметру
//                                               командной строки "/uc" или к параметру строки
//                                               соединения "uc", чтобы установить соединение с
//                                               информационной базой несмотря на блокировку.
//                                               Не применимо для блокировки сеансов области данных.
//     * ОжиданиеНачалаБлокировкиМин  - Число -  время отсрочки начала блокировки в минутах.
//     * ДлительностьБлокировкиМин    - Число -  время длительности блокировки в минутах.
//
Функция ДополнительныеПараметрыЗавершенияРаботыПользователей() 
	
	ДополнительныеПараметры = Новый Структура;
	ДополнительныеПараметры.Вставить("ИмяАдминистратораКластера", "");
	ДополнительныеПараметры.Вставить("ПарольАдминистратораКластера", "");
	ДополнительныеПараметры.Вставить("ТекстСообщения", "");
	ДополнительныеПараметры.Вставить("КодРазрешения", "КодРазрешения");
	ДополнительныеПараметры.Вставить("ОжиданиеНачалаБлокировкиМин", 0);
	ДополнительныеПараметры.Вставить("ДлительностьБлокировкиМин", 0);
	
	ДополнительныеПараметрыИзвлеченные = ДополнительныеПараметрыЗавершенияРаботыПользователейИзвлеченные();
	
	Для Каждого Параметр Из ДополнительныеПараметры Цикл 
		
		ЗначениеПараметра = Неопределено;
		
		Если ДополнительныеПараметрыИзвлеченные.Свойство(Параметр.Ключ, ЗначениеПараметра)
			И ЗначениеЗаполнено(ЗначениеПараметра) Тогда 
			
			ДополнительныеПараметры[Параметр.Ключ] = ЗначениеПараметра;
		КонецЕсли;
		
	КонецЦикла;
	
	Возврат ДополнительныеПараметры;
	
КонецФункции

Функция ДополнительныеПараметрыЗавершенияРаботыПользователейИзвлеченные()
	
	ДополнительныеПараметры = Новый Структура;
	
	ПараметрЗавершенияРаботыПользователей = ПараметрЗавершенияРаботыПользователей();
	
	Если Не ЗначениеЗаполнено(ПараметрЗавершенияРаботыПользователей) Тогда 
		Возврат ДополнительныеПараметры;
	КонецЕсли;
	
	НачальныйНомер = СтрНайти(ПараметрЗавершенияРаботыПользователей, "ЗавершитьРаботуПользователей")
		+ СтрДлина("ЗавершитьРаботуПользователей");
	
	ДополнительныеПараметрыСтрокой = СокрЛП(Сред(ПараметрЗавершенияРаботыПользователей, НачальныйНомер));
	СоставДополнительныхПараметров = СтрРазделить(ДополнительныеПараметрыСтрокой, ",");
	ПредыдущийПараметр = Неопределено;
	
	Для Каждого Параметр Из СоставДополнительныхПараметров Цикл 
		
		ОписаниеПараметра = СтрРазделить(Параметр, "=");
		
		Если ОписаниеПараметра.Количество() <> 2 Тогда 
			
			Если ПредыдущийПараметр <> Неопределено
				И ЗначениеЗаполнено(ОписаниеПараметра[0]) Тогда 
				
				ЗначениеПараметра = ДополнительныеПараметры[ПредыдущийПараметр] + "," + ОписаниеПараметра[0];
				ДополнительныеПараметры.Вставить(ПредыдущийПараметр, ЗначениеПараметра);
				
			КонецЕсли;
			
			Продолжить;
			
		КонецЕсли;
		
		ДополнительныеПараметры.Вставить(СокрЛП(ОписаниеПараметра[0]), СокрЛП(ОписаниеПараметра[1]));
		ПредыдущийПараметр = СокрЛП(ОписаниеПараметра[0]);
		
	КонецЦикла;
	
	Возврат ДополнительныеПараметрыЗавершенияРаботыПользователейНормализованные(ДополнительныеПараметры);
	
КонецФункции

Функция ПараметрЗавершенияРаботыПользователей()
	
	СоставПараметровЗапуска = СтрРазделить(ПараметрЗапуска, ";", Ложь);
	
	Для Каждого Параметр Из СоставПараметровЗапуска Цикл 
		
		Если СтрНачинаетсяС(СокрЛП(Параметр), "ЗавершитьРаботуПользователей") Тогда 
			Возврат Параметр;
		КонецЕсли;
		
	КонецЦикла;
	
	Возврат "";
	
КонецФункции

Функция ДополнительныеПараметрыЗавершенияРаботыПользователейНормализованные(ДополнительныеПараметры)
	
	ДополнительныеПараметрыНормализованные = Новый Структура;
	
	КлючиДополнительныхПараметров = КлючиДополнительныхПараметровЗавершенияРаботыПользователей();
	
	Для Каждого ДополнительныйПараметр Из ДополнительныеПараметры Цикл 
		
		Для Каждого КлючДополнительногоПараметра Из КлючиДополнительныхПараметров Цикл 
			
			Если СтрНачинаетсяС(ДополнительныйПараметр.Ключ, КлючДополнительногоПараметра.Ключ) Тогда 
				
				ДополнительныеПараметрыНормализованные.Вставить(
					КлючДополнительногоПараметра.Значение, ДополнительныйПараметр.Значение);
				
			КонецЕсли;
			
		КонецЦикла;
		
	КонецЦикла;
	
	ОтформатироватьДополнительныеПараметрыЗавершенияРаботыПользователей(ДополнительныеПараметрыНормализованные);
	
	Возврат ДополнительныеПараметрыНормализованные;
	
КонецФункции

Функция КлючиДополнительныхПараметровЗавершенияРаботыПользователей()
	
	КлючиДополнительныхПараметров = Новый Соответствие;
	КлючиДополнительныхПараметров.Вставить("Имя", "ИмяАдминистратораКластера");
	КлючиДополнительныхПараметров.Вставить("Пароль", "ПарольАдминистратораКластера");
	КлючиДополнительныхПараметров.Вставить("Сообщение", "ТекстСообщения");
	КлючиДополнительныхПараметров.Вставить("Код", "КодРазрешения");
	КлючиДополнительныхПараметров.Вставить("Ожидание", "ОжиданиеНачалаБлокировкиМин");
	КлючиДополнительныхПараметров.Вставить("Длительность", "ДлительностьБлокировкиМин");
	
	Возврат КлючиДополнительныхПараметров;
	
КонецФункции

Процедура ОтформатироватьДополнительныеПараметрыЗавершенияРаботыПользователей(ДополнительныеПараметры)
	
	ПараметрыПодлежащиеФорматированию = Новый Массив;
	ПараметрыПодлежащиеФорматированию.Добавить("ОжиданиеНачалаБлокировкиМин");
	ПараметрыПодлежащиеФорматированию.Добавить("ДлительностьБлокировкиМин");
	
	ОписаниеЧисла = Новый ОписаниеТипов("Число");
	
	Для Каждого Параметр Из ПараметрыПодлежащиеФорматированию Цикл 
		
		ЗначениеПараметра = Неопределено;
		
		Если Не ДополнительныеПараметры.Свойство(Параметр, ЗначениеПараметра) Тогда 
			Продолжить;
		КонецЕсли;
		
		ДоступныеСимволы = Новый Массив;
		
		КоличествоСимволов = СтрДлина(ЗначениеПараметра);
		
		Для НомерСимвола = 1 По КоличествоСимволов Цикл 
			
			Символ = Сред(ЗначениеПараметра, НомерСимвола, 1);
			
			Если СтрНайти("0123456789", Символ) > 0 Тогда 
				ДоступныеСимволы.Добавить(Символ);
			КонецЕсли;
			
		КонецЦикла;
		
		ЗначениеПараметраНормализованное = СтрСоединить(ДоступныеСимволы);
		
		Если ЗначениеЗаполнено(ЗначениеПараметраНормализованное) Тогда 
			ДополнительныеПараметры[Параметр] = ОписаниеЧисла.ПривестиЗначение(ЗначениеПараметраНормализованное);
		Иначе
			ДополнительныеПараметры[Параметр] = 0;
		КонецЕсли;
		
	КонецЦикла;
	
КонецПроцедуры

#КонецОбласти

Функция КлючСодержитсяВПараметрахЗапуска(ПараметрыЗапуска, Ключ)
	
	Для Каждого Параметр Из ПараметрыЗапуска Цикл 
		
		Если СтрНачинаетсяС(СокрЛП(Параметр), Ключ) Тогда 
			Возврат Истина;
		КонецЕсли;
		
	КонецЦикла;
	
	Возврат Ложь;
	
КонецФункции

Функция ПараметрыЗапускаУточненные(ПараметрыЗапуска, ДополнительныеПараметры)
	
	ИмяАдминистратораКластера = ОбщегоНазначенияКлиентСервер.СвойствоСтруктуры(
		ДополнительныеПараметры, "ИмяАдминистратораКластера");
	
	Если Не ЗначениеЗаполнено(ИмяАдминистратораКластера) Тогда 
		Возврат ПараметрыЗапуска;
	КонецЕсли;
	
	ПараметрыЗапускаУточненные = Новый Массив;
	ПараметрыЗапускаУточненные.Добавить(ПараметрыЗапуска[0]);
	ПараметрыЗапускаУточненные.Добавить(ИмяАдминистратораКластера);
	
	ПарольАдминистратораКластера = ОбщегоНазначенияКлиентСервер.СвойствоСтруктуры(
		ДополнительныеПараметры, "ПарольАдминистратораКластера");
	
	Если ЗначениеЗаполнено(ПарольАдминистратораКластера) Тогда 
		ПараметрыЗапускаУточненные.Добавить(ПарольАдминистратораКластера);
	КонецЕсли;
	
	Возврат ПараметрыЗапускаУточненные;
	
КонецФункции

#КонецОбласти
