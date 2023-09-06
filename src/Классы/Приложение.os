&Лог("twm.application")
Перем Лог;

&Пластилин
&Табакерка
Перем ОписаниеОбъекта; // каждая сравниваемая конфигурация

&Рогатка
Процедура ПриСозданииОбъекта()
    
КонецПроцедуры

Процедура ПриЗапускеПриложения() Экспорт
КонецПроцедуры

Процедура ВыполнитьСлияниеКонфигураций(
        РежимОбъединения,
        ПутьКСтаройКонфигурации,
        ПутьКОсновнойКонфигурации,
        ПутьКНовойКонфигурации,
        ПутьКВыходномуФайлу) Экспорт
    
    Лог.Информация("Начало процесса слияния конфигураций");
    
    СтараяКонфигурация = ОписаниеОбъекта.Достать();
    СтараяКонфигурация.ПрочитатьСодержимоеФайлаВКоллекцию(ПутьКСтаройКонфигурации);
    ОсновнаяКонфигурация = ОписаниеОбъекта.Достать();
    ОсновнаяКонфигурация.ПрочитатьСодержимоеФайлаВКоллекцию(ПутьКОсновнойКонфигурации);
    НоваяКонфигурация = ОписаниеОбъекта.Достать();
    НоваяКонфигурация.ПрочитатьСодержимоеФайлаВКоллекцию(ПутьКНовойКонфигурации);
    
    Результат = ОписаниеОбъекта.Достать();
    
    Если РежимОбъединения <> "new" Тогда
        УстановитьРежимЗагрузкиНовогоПриНеобходимости(РежимОбъединения, СтараяКонфигурация, ОсновнаяКонфигурация);
    КонецЕсли;
    
    РежимОбъединенияВЛог = "";
    Если РежимОбъединения = "priority_base" Тогда
        РежимОбъединенияВЛог = "Объединить с приоритетом основной конфигурации";
    ИначеЕсли РежимОбъединения = "priority_new" Тогда
        РежимОбъединенияВЛог = "Объединить с приоритетом новой конфигурации";
    Иначе
        РежимОбъединенияВЛог = "Взять из новой конфигурации поставщика";
    КонецЕсли;
    Лог.Информация(СтрШаблон("Установлен режим объединения: %1", НРег(РежимОбъединенияВЛог)));

    Если РежимОбъединения = "priority_base" Тогда
        РезультатОбъединения = ПолучитьРезультатОбъединения(
            ОсновнаяКонфигурация.ПолучитьДанные(),
            НоваяКонфигурация.ПолучитьДанные()
        );
    ИначеЕсли РежимОбъединения = "priority_new" Тогда
        РезультатОбъединения = ПолучитьРезультатОбъединения(
            НоваяКонфигурация.ПолучитьДанные(), 
            ОсновнаяКонфигурация.ПолучитьДанные()
        );
    Иначе
        РезультатОбъединения = НоваяКонфигурация.ПолучитьДанные();
    КонецЕсли;
    
    Результат.УстановитьДанные(РезультатОбъединения);
    Результат.СохранитьКонфигурациюВФайл(ПутьКВыходномуФайлу);

    Лог.Информация("Слияние конфигураций завершено");
    
КонецПроцедуры

#Область АлгоритмыСравненияОбъединения

Функция ПолучитьРезультатОбъединения(Знач ПриоритетнаяКонфигурация, Знач ВтораяКонфигурация) Экспорт
    
    Результат = Новый Массив();
    
    // Нидлман-Вунш
    Матрица = ПолучитьМатрицу(ПриоритетнаяКонфигурация, ВтораяКонфигурация);
    ОбщаяПодпоследовательность = ИзвлечьПоследовательность(Матрица, ПриоритетнаяКонфигурация, ВтораяКонфигурация);
    
    // примерка строки общей подпоследовательности к каждому модулю
    Для Каждого СтрокаОП Из ОбщаяПодпоследовательность Цикл
        
        // 1. Собираем строки приоритетного модуля, находящиеся до текущей строки общей подподследовательности
        НакопительПК = Новый Массив(); // для приоритетной конфигурации
        КоличествоСтрокКУдалению = 0; // отработанные строки потом уберем из коллекции
        Для Каждого СтрокаПК Из ПриоритетнаяКонфигурация Цикл
            КоличествоСтрокКУдалению = КоличествоСтрокКУдалению + 1;
            Если СтрокаПК = СтрокаОП Тогда
                Прервать; // здесь больше нечего искать - всё до общей строки найдено
            Иначе
                НакопительПК.Добавить(СтрокаПК);
            КонецЕсли;
        КонецЦикла;
        ДополнитьРезультатОбъединения(Результат, НакопительПК, Истина);
        ПриоритетнаяКонфигурация = УдалитьОбработанныеСтроки(ПриоритетнаяКонфигурация, КоличествоСтрокКУдалению);
        
        // 2. То же для второго модуля
        НакопительВК = Новый Массив();
        КоличествоСтрокКУдалению = 0;
        Для Каждого СтрокаВК Из ВтораяКонфигурация Цикл
            КоличествоСтрокКУдалению = КоличествоСтрокКУдалению + 1;
            Если СтрокаВК = СтрокаОП Тогда
                Прервать;
            Иначе
                НакопительВК.Добавить(СтрокаВК);
            КонецЕсли;
        КонецЦикла;
        ДополнитьРезультатОбъединения(Результат, НакопительВК, Ложь);
        ВтораяКонфигурация = УдалитьОбработанныеСтроки(ВтораяКонфигурация, КоличествоСтрокКУдалению);
        
        // 3. Осталось учесть и текущую строку ОП в итоговой коллекции
        Результат.Добавить(СтрокаОП);
        
    КонецЦикла;
    
    // 4. Если от модулей что-то еще осталось - тоже сбрасываем в результат
    ДополнитьРезультатОбъединения(Результат, ПриоритетнаяКонфигурация, Истина);
    ДополнитьРезультатОбъединения(Результат, ВтораяКонфигурация, Ложь);
    
    Возврат Результат;
    
КонецФункции

Процедура ДополнитьРезультатОбъединения(Приемник, Знач Источник, Знач ЭтоПриоритетныйМодуль)
    
    Если Не ЭтоПриоритетныйМодуль И Источник.Количество() > 0 Тогда
        Приемник.добавить("//{{MRG[ <-> ]");
    КонецЕсли;
    
    Для Каждого Значение Из Источник Цикл
        ИтоговаяСтрока = СтрШаблон("%1%2", ?(ЭтоПриоритетныйМодуль, "", "//"), Значение);
        Приемник.Добавить(ИтоговаяСтрока);
    КонецЦикла;
    
    Если Не ЭтоПриоритетныйМодуль И Источник.Количество() > 0 Тогда
        Приемник.добавить("//}}MRG[ <-> ]");
    КонецЕсли;
    
КонецПроцедуры

Функция УдалитьОбработанныеСтроки(Знач СтрокиМодуля, Знач КоличествоСтрокКУдалению)
    
    Результат = Новый Массив;
    
    Выбрано = 0;
    Для Каждого ЭлементМассива Из СтрокиМодуля Цикл
        Если Выбрано < КоличествоСтрокКУдалению Тогда
            Выбрано = Выбрано + 1;
            Продолжить;
        КонецЕсли;
        Результат.Добавить(ЭлементМассива);
    КонецЦикла;
    
    Возврат Результат;
    
КонецФункции

Функция ПолучитьМатрицу(Знач а, Знач б)
    
    Матрица = Новый Массив(а.Количество() + 1, б.Количество() + 1);
    Для х = 0 По Матрица.ВГраница() Цикл
        Для у = 0 По Матрица[х].ВГраница() Цикл
            Матрица[х][у] = 0;
        КонецЦикла;
    КонецЦикла;
    
    Для х = 1 По а.Количество() Цикл
        Для у = 1 По б.Количество() Цикл
            Если а[х - 1] = б[у - 1] Тогда
                Матрица[х][у] = Матрица[х - 1][у - 1] + 1;
            Иначе
                Матрица[х][у] = Макс(Матрица[х][у - 1], Матрица[х - 1][у]);
            КонецЕсли;
        КонецЦикла;
    КонецЦикла;
    
    Возврат Матрица;
    
КонецФункции

Функция ИзвлечьПоследовательность(Знач Матрица, Знач а, Знач б)
    
    ОбратныйМассив = Новый Массив();
    ИндексА = а.Количество();
    ИндексБ = б.Количество();
    
    Пока ИндексА > 0 И ИндексБ > 0 Цикл
        
        Если а[ИндексА - 1] = б[ИндексБ - 1] Тогда
            
            ОбратныйМассив.Добавить(а[ИндексА - 1]);
            ИндексА = ИндексА - 1;
            ИндексБ = ИндексБ - 1;
            
        ИначеЕсли Матрица[ИндексА - 1][ИндексБ] > Матрица[ИндексА][ИндексБ - 1] Тогда
            ИндексА = ИндексА - 1;
        Иначе
            ИндексБ = ИндексБ - 1;
        КонецЕсли;
        
    КонецЦикла;
    
    Результат = Новый Массив();
    Для Индекс = -ОбратныйМассив.ВГраница() По 0 Цикл
        Результат.Добавить(ОбратныйМассив[-Индекс]);
    КонецЦикла;
    
    Возврат Результат;
    
КонецФункции

#КонецОбласти
#Область СлужебныеПроцедурыИФункции

Процедура УстановитьРежимЗагрузкиНовогоПриНеобходимости(РежимОбъединения, Знач Объект1, Знач Объект2)
    
    Если Объект1.ДанныеИдентичныОбъекту(Объект2) Тогда
        РежимОбъединения = "new";
    КонецЕсли;
    
КонецПроцедуры

#КонецОбласти