﻿///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2020, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область ОписаниеПеременных

&НаКлиенте
Перем ВыполняетсяРезервноеКопирование;

#КонецОбласти

#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Если Не ОбщегоНазначения.ЭтоWindowsКлиент() Тогда
		ВызватьИсключение НСтр("ru = 'Резервное копирование и восстановление данных необходимо настроить средствами операционной системы или другими сторонними средствами.'");
	КонецЕсли;
	
	Если ОбщегоНазначения.ЭтоВебКлиент() Тогда
		ВызватьИсключение НСтр("ru = 'Резервное копирование недоступно в веб-клиенте.'");
	КонецЕсли;
	
	Если НЕ ОбщегоНазначения.ИнформационнаяБазаФайловая() Тогда
		ВызватьИсключение НСтр("ru = 'В клиент-серверном варианте работы резервное копирование следует выполнять сторонними средствами (средствами СУБД).'");
	КонецЕсли;
	
	НастройкиРезервногоКопирования = РезервноеКопированиеИБСервер.НастройкиРезервногоКопирования();
	ПарольАдминистратораИБ = НастройкиРезервногоКопирования.ПарольАдминистратораИБ;
	
	Если Параметры.РежимРаботы = "ВыполнитьСейчас" Тогда
		Элементы.СтраницыПомощника.ТекущаяСтраница = Элементы.СтраницаИнформацииИВыполненияРезервногоКопирования;
		Если Не ПустаяСтрока(Параметры.Пояснение) Тогда
			Элементы.ГруппаОжидание.ТекущаяСтраница = Элементы.СтраницаОжиданияВремениЗапуска;
			Элементы.НадписьВремяОжиданияРезервногоКопирования.Заголовок = Параметры.Пояснение;
		КонецЕсли;
	ИначеЕсли Параметры.РежимРаботы = "ВыполнитьПриЗавершенииРаботы" Тогда
		Элементы.СтраницыПомощника.ТекущаяСтраница = Элементы.СтраницаИнформацииИВыполненияРезервногоКопирования;
	ИначеЕсли Параметры.РежимРаботы = "УспешноВыполнено" Тогда
		Элементы.СтраницыПомощника.ТекущаяСтраница = Элементы.СтраницаУспешногоВыполненияКопирования;
		ИмяФайлаРезервнойКопии = Параметры.ИмяФайлаРезервнойКопии;
	ИначеЕсли Параметры.РежимРаботы = "НеВыполнено" Тогда
		Элементы.СтраницыПомощника.ТекущаяСтраница = Элементы.СтраницаОшибокПриКопировании;
	КонецЕсли;
	
	АвтоматическоеВыполнение = (Параметры.РежимРаботы = "ВыполнитьСейчас" Или Параметры.РежимРаботы = "ВыполнитьПриЗавершенииРаботы");
	
	Если НастройкиРезервногоКопирования.Свойство("КаталогХраненияРезервныхКопийПриРучномЗапуске")
		И Не ПустаяСтрока(НастройкиРезервногоКопирования.КаталогХраненияРезервныхКопийПриРучномЗапуске)
		И Не АвтоматическоеВыполнение Тогда
		Объект.КаталогСРезервнымиКопиями = НастройкиРезервногоКопирования.КаталогХраненияРезервныхКопийПриРучномЗапуске;
	Иначе
		Объект.КаталогСРезервнымиКопиями = НастройкиРезервногоКопирования.КаталогХраненияРезервныхКопий;
	КонецЕсли;
	
	Если НастройкиРезервногоКопирования.ДатаПоследнегоРезервногоКопирования = Дата(1, 1, 1) Тогда
		ТекстЗаголовка = НСтр("ru = 'Резервное копирование еще ни разу не проводилось'");
	Иначе
		ТекстЗаголовка = НСтр("ru = 'В последний раз резервное копирование проводилось: %1'");
		ДатаПоследнегоКопирования = Формат(НастройкиРезервногоКопирования.ДатаПоследнегоРезервногоКопирования, "ДЛФ=ДДВ");
		ТекстЗаголовка = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(ТекстЗаголовка, ДатаПоследнегоКопирования);
	КонецЕсли;
	Элементы.НадписьДатаПроведенияПоследнегоРезервногоКопирования.Заголовок = ТекстЗаголовка;
	Элементы.ГруппаАвтоматическоеРезервноеКопирование.Видимость = Не НастройкиРезервногоКопирования.ВыполнятьАвтоматическоеРезервноеКопирование;
	Элементы.НеДожидатьсяЗавершенияСеансов.Видимость = ОбщегоНазначения.РежимОтладки();
	
	ИнформацияОПользователе = РезервноеКопированиеИБСервер.ИнформацияОПользователе();
	ТребуетсяВводПароля = ИнформацияОПользователе.ТребуетсяВводПароля;
	Если ТребуетсяВводПароля Тогда
		АдминистраторИБ = ИнформацияОПользователе.Имя;
	Иначе
		Элементы.ГруппаАвторизации.Видимость = Ложь;
		ПарольАдминистратораИБ = "";
	КонецЕсли;
	
	РучнойЗапуск = (Элементы.СтраницыПомощника.ТекущаяСтраница = Элементы.СтраницаВыполненияРезервногоКопирования);
	Если РучнойЗапуск Тогда
		Если КоличествоСеансовИнформационнойБазы() > 1 Тогда
			Элементы.СтраницыСтатусаКопирования.ТекущаяСтраница = Элементы.СтраницаАктивныеПользователи;
		КонецЕсли;
		Элементы.Далее.Заголовок = НСтр("ru = 'Сохранить резервную копию'");
	КонецЕсли;
	
	РезервноеКопированиеИБСервер.УстановитьЗначениеНастройки("РучнойЗапускПоследнегоРезервногоКопирования", РучнойЗапуск);

КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	ПерейтиНаСтраницу(Элементы.СтраницыПомощника.ТекущаяСтраница);
	
#Если ВебКлиент Тогда
	Элементы.НадписьОбновитьВерсиюКомпоненты.Видимость = Ложь;
#КонецЕсли
	
	Если Параметры.РежимРаботы = "УспешноВыполнено"
		И ОбщегоНазначенияКлиент.ПодсистемаСуществует("ИнтернетПоддержкаПользователей.ОблачныйАрхив") Тогда
		МодульОблачныйАрхивКлиент = ОбщегоНазначенияКлиент.ОбщийМодуль("ОблачныйАрхивКлиент");
		МодульОблачныйАрхивКлиент.ВыгрузитьФайлВОблако(ЭтотОбъект.ИмяФайлаРезервнойКопии, 10);
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ПередЗакрытием(Отказ, ЗавершениеРаботы, ТекстПредупреждения, СтандартнаяОбработка)
	
	ТекущаяСтраница = Элементы.СтраницыПомощника.ТекущаяСтраница;
	Если ТекущаяСтраница <> Элементы.СтраницыПомощника.ПодчиненныеЭлементы.СтраницаИнформацииИВыполненияРезервногоКопирования Тогда
		Возврат;
	КонецЕсли;
	
	ТекстПредупреждения = НСтр("ru = 'Прервать подготовку к резервному копированию данных?'");
	ОбщегоНазначенияКлиент.ПоказатьПодтверждениеЗакрытияПроизвольнойФормы(ЭтотОбъект,
		Отказ, ЗавершениеРаботы, ТекстПредупреждения, "ЗакрытьФормуБезусловно");
	
КонецПроцедуры

&НаКлиенте
Процедура ПриЗакрытии(ЗавершениеРаботы)
	
	Если ЗавершениеРаботы Тогда
		Возврат;
	КонецЕсли;
	
	ОтключитьОбработчикОжидания("ИстечениеВремениОжидания");
	ОтключитьОбработчикОжидания("ПроверкаНаЕдинственностьПодключения");
	ОтключитьОбработчикОжидания("ЗавершитьРаботуПользователей");
	
	Если ВыполняетсяРезервноеКопирование = Истина Тогда
		Возврат;
	КонецЕсли;
	
	СоединенияИБКлиент.УстановитьПризнакЗавершитьВсеСеансыКромеТекущего(Ложь);
	СоединенияИБКлиент.УстановитьПризнакРаботаПользователейЗавершается(Ложь);
	СоединенияИБВызовСервера.РазрешитьРаботуПользователей();
	
	Если ПроцессВыполняется() Тогда
		УстановитьПроцессВыполняется(Ложь);
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ОбработкаОповещения(ИмяСобытия, Параметр, Источник)
	Если ИмяСобытия = "ЗавершениеРаботыПользователей" И Параметр.КоличествоСеансов <= 1
		И ПараметрыПриложения["СтандартныеПодсистемы.ПараметрыРезервногоКопированияИБ"].ПроцессВыполняется Тогда
			НачатьРезервноеКопирование();
	КонецЕсли;
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовШапкиФормы

&НаКлиенте
Процедура СписокПользователейНажатие(Элемент)
	
	СтандартныеПодсистемыКлиент.ОткрытьСписокАктивныхПользователей(, ЭтотОбъект);
	
КонецПроцедуры

&НаКлиенте
Процедура ПутьККаталогуАрхивовНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	
	ВыбранныйПуть = ПолучитьПуть(РежимДиалогаВыбораФайла.ВыборКаталога);
	Если Не ПустаяСтрока(ВыбранныйПуть) Тогда 
		Объект.КаталогСРезервнымиКопиями = ВыбранныйПуть;
	КонецЕсли;

КонецПроцедуры

&НаКлиенте
Процедура ИмяФайлаРезервнойКопииОткрытие(Элемент, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	ФайловаяСистемаКлиент.ОткрытьПроводник(ИмяФайлаРезервнойКопии);
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура Далее(Команда)
	
	ОчиститьСообщения();
	
	Если Не ПроверитьЗаполнениеРеквизитов() Тогда
		Возврат;
	КонецЕсли;
	
	ТекущаяСтраницаПомощника = Элементы.СтраницыПомощника.ТекущаяСтраница;
	Если ТекущаяСтраницаПомощника = Элементы.СтраницыПомощника.ПодчиненныеЭлементы.СтраницаВыполненияРезервногоКопирования Тогда
		ПерейтиНаСтраницу(Элементы.СтраницаИнформацииИВыполненияРезервногоКопирования);
		УстановитьПутьАрхиваСКопиями(Объект.КаталогСРезервнымиКопиями);
	Иначе
		Закрыть();
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура Отмена(Команда)
	
	Закрыть();
	
КонецПроцедуры

&НаКлиенте
Процедура ПерейтиВЖурналРегистрации(Команда)
	ОткрытьФорму("Обработка.ЖурналРегистрации.Форма.ЖурналРегистрации", , ЭтотОбъект);
КонецПроцедуры

&НаКлиенте
Процедура НеДожидатьсяЗавершенияСеансов(Команда)
	НачатьРезервноеКопирование();
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаКлиенте
Процедура ПерейтиНаСтраницу(НоваяСтраница)
	
	ПерейтиДалее = Истина;
	ПодчиненныеСтраницы = Элементы.СтраницыПомощника.ПодчиненныеЭлементы;
	Если НоваяСтраница = ПодчиненныеСтраницы.СтраницаИнформацииИВыполненияРезервногоКопирования Тогда
		ПерейтиНаСтраницуИнформацииИВыполненияРезервногоКопирования(ПерейтиДалее);
	ИначеЕсли НоваяСтраница = ПодчиненныеСтраницы.СтраницаОшибокПриКопировании 
		ИЛИ НоваяСтраница = ПодчиненныеСтраницы.СтраницаУспешногоВыполненияКопирования Тогда
		ПерейтиНаСтраницуРезультатовРезервногоКопирования();
	КонецЕсли;
	
	Если Не ПерейтиДалее Тогда
		Возврат;
	КонецЕсли;
	
	Если НоваяСтраница <> Неопределено Тогда
		Элементы.СтраницыПомощника.ТекущаяСтраница = НоваяСтраница;
	Иначе
		Закрыть();
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ПерейтиНаСтраницуИнформацииИВыполненияРезервногоКопирования(ПерейтиДалее)
	
	Если Не ПроверитьЗаполнениеРеквизитов() Тогда
		Возврат;
	КонецЕсли;
	
	ПроверитьНаличиеБлокирующихСеансов();
	Оповещение = Новый ОписаниеОповещения(
		"ПерейтиНаСтраницуРезервногоКопированияПослеПроверкиДоступаКИнформационнойБазе", ЭтотОбъект);
	РезервноеКопированиеИБКлиент.ПроверитьДоступКИнформационнойБазе(ПарольАдминистратораИБ, Оповещение);
	
КонецПроцедуры

&НаКлиенте
Процедура ПерейтиНаСтраницуРезервногоКопированияПослеПроверкиДоступаКИнформационнойБазе(РезультатПодключения, Контекст) Экспорт
	
	Если РезультатПодключения.ОшибкаПодключенияКомпоненты Тогда
		Элементы.СтраницыПомощника.ТекущаяСтраница = Элементы.СтраницаВыполненияРезервногоКопирования;
		Элементы.СтраницыСтатусаКопирования.ТекущаяСтраница = Элементы.СтраницаОшибкаПодключения;
		ОбнаруженнаяОшибкаПодключения = РезультатПодключения.КраткоеОписаниеОшибки;
		Возврат;
	КонецЕсли;
	
	УстановитьПараметрыРезервногоКопирования();
	УстановитьПроцессВыполняется(Истина);
	
	КоличествоСеансовИнформационнойБазы = ПроверитьНаличиеБлокирующихСеансов();
	
	Элементы.Отмена.Доступность = Истина;
	Элементы.Далее.Доступность = Ложь;
	УстановитьЗаголовокКнопкиДалее(Истина);
	
	СоединенияИБВызовСервера.УстановитьБлокировкуСоединений(НСтр("ru = 'Выполняется восстановление информационной базы.'"), "РезервноеКопирование");
	
	Если КоличествоСеансовИнформационнойБазы = 1 Тогда
		СоединенияИБКлиент.УстановитьПризнакЗавершитьВсеСеансыКромеТекущего(Истина);
		СоединенияИБКлиент.УстановитьПризнакРаботаПользователейЗавершается(Истина);
		НачатьРезервноеКопирование();
	Иначе
		СоединенияИБКлиент.УстановитьОбработчикиОжиданияЗавершенияРаботыПользователей(Истина);
		УстановитьОбработчикОжиданияНачалаРезервногоКопирования();
		УстановитьОбработчикОжиданияИстеченияТаймаутаРезервногоКопирования();
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Функция ПроверитьНаличиеБлокирующихСеансов()
	
	КоличествоСеансовИнформационнойБазы = КоличествоСеансовИнформационнойБазы();
	Элементы.КоличествоАктивныхПользователей.Заголовок = КоличествоСеансовИнформационнойБазы;
	
	ИнформацияОБлокирующихСеансах = СоединенияИБ.ИнформацияОБлокирующихСеансах("");
	ИмеютсяБлокирующиеСеансы = ИнформацияОБлокирующихСеансах.ИмеютсяБлокирующиеСеансы;
	
	Если ИмеютсяБлокирующиеСеансы Тогда
		Элементы.ДекорацияАктивныеСеансы.Заголовок = ИнформацияОБлокирующихСеансах.ТекстСообщения;
	КонецЕсли;
	
	Элементы.ДекорацияАктивныеСеансы.Видимость = ИмеютсяБлокирующиеСеансы;
	Возврат КоличествоСеансовИнформационнойБазы;
	
КонецФункции

&НаКлиенте
Процедура ПерейтиНаСтраницуРезультатовРезервногоКопирования()
	
	Элементы.Далее.Видимость = Ложь;
	Элементы.Отмена.Заголовок = НСтр("ru = 'Закрыть'");
	Элементы.Отмена.КнопкаПоУмолчанию = Истина;
	
	Настройки = НастройкиРезервногоКопирования();
	РезервноеКопированиеИБКлиент.ЗаполнитьЗначенияГлобальныхПеременных(Настройки);
	
	СброситьПризнакРезервногоКопирования();
	
КонецПроцедуры

&НаСервереБезКонтекста
Процедура СброситьПризнакРезервногоКопирования()
	
	РезервноеКопированиеИБСервер.СброситьПризнакРезервногоКопирования();
	
КонецПроцедуры

&НаСервере
Процедура УстановитьПараметрыРезервногоКопирования()
	
	Настройки = РезервноеКопированиеИБСервер.НастройкиРезервногоКопирования();
	Настройки.Вставить("АдминистраторИБ", АдминистраторИБ);
	Настройки.Вставить("ПарольАдминистратораИБ", ?(ТребуетсяВводПароля, ПарольАдминистратораИБ, ""));
	РезервноеКопированиеИБСервер.УстановитьНастройкиРезервногоКопирования(Настройки);
	
КонецПроцедуры

&НаСервереБезКонтекста
Функция НастройкиРезервногоКопирования()
	
	Возврат РезервноеКопированиеИБСервер.НастройкиРезервногоКопирования();
	
КонецФункции

&НаКлиенте
Функция ПроверитьЗаполнениеРеквизитов()

#Если ВебКлиент Тогда
	ТекстСообщения = НСтр("ru = 'Создание резервной копии не доступно в веб-клиенте.'");
	ОбщегоНазначенияКлиент.СообщитьПользователю(ТекстСообщения);
	РеквизитыЗаполнены = Ложь;
#Иначе
	
	РеквизитыЗаполнены = Истина;
	
	Объект.КаталогСРезервнымиКопиями = СокрЛП(Объект.КаталогСРезервнымиКопиями);
	
	Если ПустаяСтрока(Объект.КаталогСРезервнымиКопиями) Тогда
		ТекстСообщения = НСтр("ru = 'Не выбран каталог для резервной копии.'");
		ОбщегоНазначенияКлиент.СообщитьПользователю(ТекстСообщения,, "Объект.КаталогСРезервнымиКопиями");
		РеквизитыЗаполнены = Ложь;
	ИначеЕсли НайтиФайлы(Объект.КаталогСРезервнымиКопиями).Количество() = 0 Тогда
		ТекстСообщения = НСтр("ru = 'Указан несуществующий каталог.'");
		ОбщегоНазначенияКлиент.СообщитьПользователю(ТекстСообщения,, "Объект.КаталогСРезервнымиКопиями");
		РеквизитыЗаполнены = Ложь;
	Иначе
		
		ИмяФайла = "test.test1С";
		Попытка
			ТестовыйФайл = Новый ЗаписьXML;
			ТестовыйФайл.ОткрытьФайл(Объект.КаталогСРезервнымиКопиями + "/" + ИмяФайла);
			ТестовыйФайл.ЗаписатьОбъявлениеXML();
			ТестовыйФайл.Закрыть();
		Исключение
			ТекстСообщения = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
				НСтр("ru = 'Нет прав на запись в каталог с резервными копиями.
					|Не удалось создать тестовый файл %1 по причине: %2'"),
				ИмяФайла, КраткоеПредставлениеОшибки(ИнформацияОбОшибке()));
			ОбщегоНазначенияКлиент.СообщитьПользователю(ТекстСообщения,, "Объект.КаталогСРезервнымиКопиями");
			РеквизитыЗаполнены = Ложь;
		КонецПопытки;
		
		Если РеквизитыЗаполнены Тогда
			
			// АПК:280-выкл Исключение не обрабатываем т.к. на этом шаге не происходит удаления файлов.
			Попытка
				УдалитьФайлы(Объект.КаталогСРезервнымиКопиями, "*.test1С");
			Исключение
			КонецПопытки;
			// АПК:280-вкл
			
		КонецЕсли;
		
	КонецЕсли;
	
	Если ТребуетсяВводПароля И ПустаяСтрока(ПарольАдминистратораИБ) Тогда
		ТекстСообщения = НСтр("ru = 'Не задан пароль администратора.'");
		ОбщегоНазначенияКлиент.СообщитьПользователю(ТекстСообщения,, "ПарольАдминистратораИБ");
		РеквизитыЗаполнены = Ложь;
	КонецЕсли;

#КонецЕсли
	
	Возврат РеквизитыЗаполнены;
	
КонецФункции

&НаКлиенте
Процедура УстановитьОбработчикОжиданияИстеченияТаймаутаРезервногоКопирования()
	
	ПодключитьОбработчикОжидания("ИстечениеВремениОжидания", 300, Истина);
	
КонецПроцедуры

&НаКлиенте
Процедура ИстечениеВремениОжидания()
	
	ОтключитьОбработчикОжидания("ПроверкаНаЕдинственностьПодключения");
	ТекстВопроса = НСтр("ru = 'Не удалось отключить всех пользователей от базы. Провести резервное копирование? (возможны ошибки при архивации)'");
	ТекстПояснения = НСтр("ru = 'Не удалось отключить пользователя.'");
	ОписаниеОповещения = Новый ОписаниеОповещения("ИстечениеВремениОжиданияЗавершение", ЭтотОбъект);
	ПоказатьВопрос(ОписаниеОповещения, ТекстВопроса, РежимДиалогаВопрос.ДаНет, 30, КодВозвратаДиалога.Нет, ТекстПояснения, КодВозвратаДиалога.Нет);
	
КонецПроцедуры

&НаКлиенте
Процедура ИстечениеВремениОжиданияЗавершение(Ответ, ДополнительныеПараметры) Экспорт
	
	Если Ответ = КодВозвратаДиалога.Да Тогда
		НачатьРезервноеКопирование();
	Иначе
		ОчиститьСообщения();
		СоединенияИБКлиент.УстановитьПризнакЗавершитьВсеСеансыКромеТекущего(Ложь);
		ОтменитьПодготовку();
КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура ОтменитьПодготовку()
	
	Элементы.НадписьНеУдалось.Заголовок = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(НСтр("ru = '%1.
		|Подготовка к резервному копированию отменена. Информационная база разблокирована.'"),
		СоединенияИБ.СообщениеОНеотключенныхСеансах());
	Элементы.СтраницыПомощника.ТекущаяСтраница = Элементы.СтраницаОшибокПриКопировании;
	Элементы.ПерейтиВЖурналРегистрации1.Видимость = Ложь;
	Элементы.Далее.Видимость = Ложь;
	Элементы.Отмена.Заголовок = НСтр("ru = 'Закрыть'");
	Элементы.Отмена.КнопкаПоУмолчанию = Истина;
	
	СоединенияИБ.РазрешитьРаботуПользователей();
	
КонецПроцедуры

&НаКлиенте
Процедура УстановитьОбработчикОжиданияНачалаРезервногоКопирования()
	
	ПодключитьОбработчикОжидания("ПроверкаНаЕдинственностьПодключения", 5);
	
КонецПроцедуры

&НаКлиенте
Процедура ПроверкаНаЕдинственностьПодключения()
	
	КоличествоПользователей = КоличествоСеансовИнформационнойБазы();
	Элементы.КоличествоАктивныхПользователей.Заголовок = Строка(КоличествоПользователей);
	Если КоличествоПользователей = 1 Тогда
		НачатьРезервноеКопирование();
	Иначе
		ПроверитьНаличиеБлокирующихСеансов();
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура УстановитьЗаголовокКнопкиДалее(ЭтоКнопкаДалее)
	
	Элементы.Далее.Заголовок = ?(ЭтоКнопкаДалее, НСтр("ru = 'Далее >'"), НСтр("ru = 'Готово'"));
	
КонецПроцедуры

&НаКлиенте
Функция ПолучитьПуть(РежимДиалога)
	
	Режим = РежимДиалога;
	ДиалогОткрытияФайла = Новый ДиалогВыбораФайла(Режим);
	Если Режим = РежимДиалогаВыбораФайла.ВыборКаталога Тогда
		ДиалогОткрытияФайла.Заголовок= НСтр("ru = 'Выберите каталог'");
	Иначе
		ДиалогОткрытияФайла.Заголовок= НСтр("ru = 'Выберите файл'");
	КонецЕсли;	
		
	Если ДиалогОткрытияФайла.Выбрать() Тогда
		Если РежимДиалога = РежимДиалогаВыбораФайла.ВыборКаталога Тогда
			Возврат ДиалогОткрытияФайла.Каталог;
		Иначе
			Возврат ДиалогОткрытияФайла.ПолноеИмяФайла;
		КонецЕсли;
	КонецЕсли;
	
КонецФункции

&НаКлиенте
Процедура НачатьРезервноеКопирование()
	
#Если Не ВебКлиент И Не МобильныйКлиент Тогда
	
	РезервноеКопированиеИБКлиент.НеОстанавливатьВыполнениеСценариев();
	
	ИмяГлавногоФайлаСкрипта = СформироватьФайлыСкрипта();
	
	ЖурналРегистрацииКлиент.ДобавитьСообщениеДляЖурналаРегистрации(
		РезервноеКопированиеИБКлиент.СобытиеЖурналаРегистрации(),
		"Информация", 
		НСтр("ru = 'Выполняется резервное копирование информационной базы:'") + " " + ИмяГлавногоФайлаСкрипта);
		
	Если Параметры.РежимРаботы = "ВыполнитьСейчас" Или Параметры.РежимРаботы = "ВыполнитьПриЗавершенииРаботы" Тогда
		РезервноеКопированиеИБКлиент.УдалитьРезервныеКопииПоНастройке();
	КонецЕсли;
	
	ВыполняетсяРезервноеКопирование = Истина;
	ЗакрытьФормуБезусловно = Истина;
	
	ПараметрыПриложения.Вставить("СтандартныеПодсистемы.ПропуститьПредупреждениеПередЗавершениемРаботыСистемы", Истина);
	
	ПутьКПрограммеЗапуска = СтандартныеПодсистемыКлиент.КаталогСистемныхПриложений() + "mshta.exe";
	
	СтрокаЗапуска = """%1"" ""%2"" [p1]%3[/p1]";
	СтрокаЗапуска = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
		СтрокаЗапуска,
		ПутьКПрограммеЗапуска, 
		ИмяГлавногоФайлаСкрипта, 
		РезервноеКопированиеИБКлиент.СтрокаUnicode(ПарольАдминистратораИБ));
	
	ПараметрыЗапускаПрограммы = ФайловаяСистемаКлиент.ПараметрыЗапускаПрограммы();
	ПараметрыЗапускаПрограммы.Оповещение = Новый ОписаниеОповещения("ПослеЗапускаСкрипта", ЭтотОбъект);
	ПараметрыЗапускаПрограммы.ДождатьсяЗавершения = Ложь;
	
	ФайловаяСистемаКлиент.ЗапуститьПрограмму(СтрокаЗапуска, ПараметрыЗапускаПрограммы);
	
#КонецЕсли
	
КонецПроцедуры

&НаКлиенте
Процедура ПослеЗапускаСкрипта(Результат, Контекст) Экспорт
	
	Если Результат.ПриложениеЗапущено Тогда 
		ПрекратитьРаботуСистемы();
	Иначе 
		ПоказатьПредупреждение(, Результат.ОписаниеОшибки);
	КонецЕсли;
	
КонецПроцедуры

/////////////////////////////////////////////////////////////////////////////////////////////////////////
// Обработчики событий формы на сервере и изменения настроек резервного копирования.

&НаСервереБезКонтекста
Процедура УстановитьПутьАрхиваСКопиями(Путь)
	
	НастройкиПути = РезервноеКопированиеИБСервер.НастройкиРезервногоКопирования();
	НастройкиПути.Вставить("КаталогХраненияРезервныхКопийПриРучномЗапуске", Путь);
	РезервноеКопированиеИБСервер.УстановитьНастройкиРезервногоКопирования(НастройкиПути);
	
КонецПроцедуры

//////////////////////////////////////////////////////////////////////////////////////////////////////////
// Процедуры и функции подготовки резервного копирования.

#Если Не ВебКлиент И Не МобильныйКлиент Тогда

&НаКлиенте
Функция СформироватьФайлыСкрипта()
	
	ПараметрыРезервногоКопирования = РезервноеКопированиеИБКлиент.КлиентскиеПараметрыРезервногоКопирования();
	ПараметрыРаботыКлиентаПриЗапуске = СтандартныеПодсистемыКлиент.ПараметрыРаботыКлиентаПриЗапуске();
	СоздатьКаталог(ПараметрыРезервногоКопирования.КаталогВременныхФайловОбновления);
	
	ПараметрыСкрипта = РезервноеКопированиеИБКлиент.ОбщиеПараметрыСкрипта();
	ПараметрыСкрипта.КаталогПрограммы = Параметры.КаталогПрограммы;
	ПараметрыСкрипта.ИмяФайлаПрограммы = ПараметрыРезервногоКопирования.ИмяФайлаПрограммы;
	ПараметрыСкрипта.СобытиеЖурналаРегистрации = ПараметрыРезервногоКопирования.СобытиеЖурналаРегистрации;
	ПараметрыСкрипта.ИмяCOMСоединителя = ПараметрыРаботыКлиентаПриЗапуске.ИмяCOMСоединителя;
	ПараметрыСкрипта.ЭтоБазоваяВерсияКонфигурации = ПараметрыРаботыКлиентаПриЗапуске.ЭтоБазоваяВерсияКонфигурации;
	ПараметрыСкрипта.ПараметрыСкрипта = РезервноеКопированиеИБКлиент.ПараметрыАутентификацииАдминистратораОбновления(ПарольАдминистратораИБ);
	ПараметрыСкрипта.ПараметрыЗапускаПредприятия = ОбщегоНазначенияСлужебныйКлиент.ПараметрыЗапускаПредприятияИзСкрипта();
	
	Скрипты = СформироватьТекстСкриптов(ПараметрыСкрипта, ПараметрыПриложения["СтандартныеПодсистемы.СообщенияДляЖурналаРегистрации"]);
	
	// Вспомогательный файл main.js.
	ФайлСкрипта = Новый ТекстовыйДокумент;
	ФайлСкрипта.Вывод = ИспользованиеВывода.Разрешить;
	ФайлСкрипта.УстановитьТекст(Скрипты.Скрипт);
	ИмяФайлаСкрипта = ПараметрыРезервногоКопирования.КаталогВременныхФайловОбновления + "main.js";
	ФайлСкрипта.Записать(ИмяФайлаСкрипта, РезервноеКопированиеИБКлиент.КодировкаФайловПрограммыРезервногоКопированияИБ());
	
	// Вспомогательный файл helpers.js.
	ФайлСкрипта = Новый ТекстовыйДокумент;
	ФайлСкрипта.Вывод = ИспользованиеВывода.Разрешить;
	ФайлСкрипта.УстановитьТекст(Скрипты.ДопФайлРезервногоКопирования);
	ФайлСкрипта.Записать(ПараметрыРезервногоКопирования.КаталогВременныхФайловОбновления + "helpers.js", 
		РезервноеКопированиеИБКлиент.КодировкаФайловПрограммыРезервногоКопированияИБ());
	
	БиблиотекаКартинок.ЗаставкаВнешнейОперации.Записать(ПараметрыРезервногоКопирования.КаталогВременныхФайловОбновления + "splash.png");
	БиблиотекаКартинок.ЗначокЗаставкиВнешнейОперации.Записать(ПараметрыРезервногоКопирования.КаталогВременныхФайловОбновления + "splash.ico");
	БиблиотекаКартинок.ДлительнаяОперация48.Записать(ПараметрыРезервногоКопирования.КаталогВременныхФайловОбновления + "progress.gif");
	
	// Главный файл заставки splash.hta.
	ИмяГлавногоФайлаСкрипта = ПараметрыРезервногоКопирования.КаталогВременныхФайловОбновления + "splash.hta";
	ФайлСкрипта = Новый ТекстовыйДокумент;
	ФайлСкрипта.Вывод = ИспользованиеВывода.Разрешить;
	ФайлСкрипта.УстановитьТекст(Скрипты.ЗаставкаРезервногоКопирования);
	ФайлСкрипта.Записать(ИмяГлавногоФайлаСкрипта, РезервноеКопированиеИБКлиент.КодировкаФайловПрограммыРезервногоКопированияИБ());
	
	ФайлЛога = Новый ТекстовыйДокумент;
	ФайлЛога.Вывод = ИспользованиеВывода.Разрешить;
	ФайлЛога.УстановитьТекст(СтандартныеПодсистемыКлиент.ИнформацияДляПоддержки());
	ФайлЛога.Записать(ПараметрыРезервногоКопирования.КаталогВременныхФайловОбновления + "templog.txt", КодировкаТекста.Системная);
	
	Возврат ИмяГлавногоФайлаСкрипта;
	
КонецФункции

#КонецЕсли

&НаСервере
Функция СформироватьТекстСкриптов(Знач ПараметрыСкрипта, Знач СообщенияДляЖурналаРегистрации)
	
	ЖурналРегистрации.ЗаписатьСобытияВЖурналРегистрации(СообщенияДляЖурналаРегистрации);
	
	Результат = Новый Структура("Скрипт, ДопФайлРезервногоКопирования, ЗаставкаРезервногоКопирования");
	Результат.Скрипт = СформироватьТекстСкрипта(ПараметрыСкрипта);
	Результат.ДопФайлРезервногоКопирования = Обработки.РезервноеКопированиеИБ.ПолучитьМакет("ДопФайлРезервногоКопирования").ПолучитьТекст();
	Результат.ЗаставкаРезервногоКопирования = СформироватьТекстЗаставки();
	Возврат Результат;
	
КонецФункции

&НаСервере
Функция СформироватьТекстСкрипта(ПараметрыСкрипта)
	
	// Файл обновления конфигурации: main.js.
	ШаблонСкрипта = Обработки.РезервноеКопированиеИБ.ПолучитьМакет("МакетФайлаРезервногоКопирования");
	
	Скрипт = ШаблонСкрипта.ПолучитьОбласть("ОбластьПараметров");
	Скрипт.УдалитьСтроку(1);
	Скрипт.УдалитьСтроку(Скрипт.КоличествоСтрок());
	
	Текст = ШаблонСкрипта.ПолучитьОбласть("ОбластьРезервногоКопирования");
	Текст.УдалитьСтроку(1);
	Текст.УдалитьСтроку(Текст.КоличествоСтрок());
	
	Возврат ВставитьПараметрыСкрипта(Скрипт.ПолучитьТекст(), ПараметрыСкрипта) + Текст.ПолучитьТекст();
	
КонецФункции

&НаСервере
Функция ВставитьПараметрыСкрипта(Знач Текст, Знач ПараметрыСкрипта)
	
	ИмяКаталога = ПроверитьКаталогНаУказаниеКорневогоЭлемента(Объект.КаталогСРезервнымиКопиями);
	
	ПараметрыТекста = РезервноеКопированиеИБСервер.ПодготовитьОбщиеПараметрыСкрипта(ПараметрыСкрипта);
	ПараметрыТекста["[СоздаватьРезервнуюКопию]"] = "true";
	ПараметрыТекста["[КаталогРезервнойКопии]"] = РезервноеКопированиеИБСервер.ПодготовитьТекст(ИмяКаталога + "\backup" + СтрокаКаталогаИзДаты());
	ПараметрыТекста["[ВосстанавливатьИнформационнуюБазу]"] = "false";
	ПараметрыТекста["[ВыполнитьПриЗавершенииРаботы]"] = ?(Параметры.РежимРаботы = "ВыполнитьПриЗавершенииРаботы", "true", "false");
	
	Возврат РезервноеКопированиеИБСервер.ПодставитьПараметрыВТекст(Текст, ПараметрыТекста);
	
КонецФункции

&НаСервере
Функция СформироватьТекстЗаставки()
	
	ШаблонТекста = Обработки.РезервноеКопированиеИБ.ПолучитьМакет("ЗаставкаРезервногоКопирования").ПолучитьТекст();
	
	ПараметрыТекста = Новый Соответствие;
	ПараметрыТекста["[ЗаголовокЗаставки]"] = НСтр("ru = 'Резервное копирование информационной базы...'");
	ПараметрыТекста["[ТекстЗаставки]"] = 
		НСтр("ru = 'Пожалуйста, подождите.
    		|<br /> Выполняется резервное копирование базы.
			|<br /> Не рекомендуется останавливать процесс.'");
	ПараметрыТекста["[Шаг1Инициализация]"] = НСтр("ru = 'Инициализация'");
	ПараметрыТекста["[Шаг2СозданиеРезервнойКопии]"] = НСтр("ru = 'Создание резервной копии информационной базы'");
	ПараметрыТекста["[Шаг3ОжиданиеЗавершения]"] = НСтр("ru = 'Ожидание завершения резервного копирования'");
	ПараметрыТекста["[Шаг4РазрешениеПодключений]"] = НСтр("ru = 'Разрешение подключений новых соединений'");
	ПараметрыТекста["[Шаг5Завершение]"] = НСтр("ru = 'Завершение'");
	ПараметрыТекста["[ПроцессПрерван]"] = НСтр("ru = 'Внимание: процесс резервного копирования был прерван, и информационная база осталась заблокированной.'");
	ПараметрыТекста["[ПроцессПрерванПодсказка]"] = НСтр("ru = 'Для разблокирования информационной базы воспользуйтесь консолью кластера серверов или запустите ""1С:Предприятие"".'");
	
	Возврат РезервноеКопированиеИБСервер.ПодставитьПараметрыВТекст(ШаблонТекста, ПараметрыТекста);;
	
КонецФункции

&НаСервере
Функция ПроверитьКаталогНаУказаниеКорневогоЭлемента(СтрокаКаталога)
	
	Если СтрЗаканчиваетсяНа(СтрокаКаталога, ":\") Тогда
		Возврат Лев(СтрокаКаталога, СтрДлина(СтрокаКаталога) - 1) ;
	Иначе
		Возврат СтрокаКаталога;
	КонецЕсли;
	
КонецФункции

&НаСервере
Функция СтрокаКаталогаИзДаты()
	
	СтрокаВозврата = "";
	ДатаСейчас = ТекущаяДатаСеанса();
	СтрокаВозврата = Формат(ДатаСейчас, "ДФ = гггг_ММ_дд_ЧЧ_мм_сс");
	Возврат СтрокаВозврата;
	
КонецФункции

&НаКлиенте
Процедура НадписьОбновитьВерсиюКомпонентыОбработкаНавигационнойСсылки(Элемент, НавигационнаяСсылка, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	ОбщегоНазначенияКлиент.ЗарегистрироватьCOMСоединитель();
	
КонецПроцедуры

&НаСервереБезКонтекста
Функция КоличествоСеансовИнформационнойБазы()
	
	Возврат СоединенияИБ.КоличествоСеансовИнформационнойБазы(Ложь, Ложь);
	
КонецФункции

&НаКлиенте
Функция ПроцессВыполняется()
	
	Настройки = ПараметрыПриложения["СтандартныеПодсистемы.ПараметрыРезервногоКопированияИБ"];
	Если Настройки = Неопределено Тогда
		НовыеНастройки = НастройкиРезервногоКопирования();
		РезервноеКопированиеИБКлиент.ЗаполнитьЗначенияГлобальныхПеременных(НовыеНастройки);
		Настройки = ПараметрыПриложения["СтандартныеПодсистемы.ПараметрыРезервногоКопированияИБ"];
	КонецЕсли;	
	Возврат ?(Настройки.ПроцессВыполняется <> Неопределено, Настройки.ПроцессВыполняется, Ложь);
	
КонецФункции

&НаКлиенте
Процедура УстановитьПроцессВыполняется(Знач ПроцессВыполняется)
	
	Настройки = ПараметрыПриложения["СтандартныеПодсистемы.ПараметрыРезервногоКопированияИБ"];
	Если Настройки = Неопределено Тогда
		НовыеНастройки = НастройкиРезервногоКопирования();
		РезервноеКопированиеИБКлиент.ЗаполнитьЗначенияГлобальныхПеременных(НовыеНастройки);
		Настройки = ПараметрыПриложения["СтандартныеПодсистемы.ПараметрыРезервногоКопированияИБ"];
	КонецЕсли;	
	Настройки.ПроцессВыполняется = ПроцессВыполняется;
	РезервноеКопированиеИБВызовСервера.УстановитьЗначениеНастройки("ПроцессВыполняется", ПроцессВыполняется);
	
КонецПроцедуры

#КонецОбласти
