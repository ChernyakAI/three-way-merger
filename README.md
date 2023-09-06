# Three-way-merger

Консольное приложение, основанное на библиотеках [ОСени](https://github.com/autumn-library), предназначено для трёхстороннего сравнения-объединения модулей. Поведение схоже с тем, как работает сравнение-объединение в конфигураторе платформы 1С:Предприятие 8.

#### Варианты использования

###### 1. Запуск с помощью исходного кода
1. Клонируйте исходные коды на локальный компьютер.
2. Запустите приложение в настроенном окружении:
```code
oscript src/main.os
```
3. Сконфигурируйте строку запуска в соответствии со справкой по доступным командам.

Пример запуска
```
oscript src/main.os merge --old test_files/old.bsl --base test_files/base.bsl --new test_files/new.bsl --result test_files/result.bsl --mode priority_new 
```

###### 2. Использование в качестве библиотеки

Скачать файл *.ospx из раздела releases.
Установить скачанный пакет с помощью [команды](https://github.com/oscript-library/opm):
```code
opm install -f <ПутьКФайлу>
```
Создать файл [oscript](https://oscript.io/) следующего содержания:
```code
#Использовать autumn
#Использовать autumn-logos
#Использовать twm

Режим = "priority_new";
ПутьСтарая = "test_files/old.bsl";
ПутьОсновная = "test_files/base.bsl";
ПутьНовая = "test_files/new.bsl";
Результат = "test_files/result.bsl";

Поделка = Новый Поделка();
Поделка.ЗапуститьПриложение();
Приложение = Поделка.НайтиЖелудь("Приложение");
Приложение.ВыполнитьСлияниеКонфигураций(Режим, ПутьСтарая, ПутьОсновная, ПутьНовая, Результат);
```
#### Что можно придумать ещё?

kdiff - это, конечно, наше всё, но можно попробовать тоже вклиниться в конфигуратор.
Воспользуемся утилитой, представленной в [этом](https://github.com/zeegin/vscode-merge-tool-adapter-cli) репозитории и модифицируем её. В итоге получим следующий командный файл:
```
@ECHO OFF
SETLOCAL

SET command="c:/Program Files/OneScript/bin/oscript.exe"
SET arg="%~dp0src/main.os"

@REM --merge %baseCfg %secondCfg %oldVendorCfg %merged

if /%1/==/--merge/ (
    echo f | xcopy /f /y %2 "%~2.bsl"
    echo f | xcopy /f /y %3 "%~3.bsl"
    echo f | xcopy /f /y %4 "%~4.bsl"
    echo f | xcopy /f /y %3 "%~5.bsl"
    %command% %arg% M --old "%~4.bsl" --base "%~2.bsl" --new "%~3.bsl" --result "%~5.bsl" --mode "priority_new"
    echo f | xcopy /f /y "%~5.bsl" %5
)
```
Сам файл можно скачать здесь же (twm-adapter.cmd).
Подключаем в конфигураторе:
1. Наименование: twm
2. Исполняемый файл: путь к адаптеру
3. Трехстороннее объединение: --merge %baseCfg %secondCfg %oldVendorCfg %merged
4. Автоматическое трехсторонее объединение: --merge %baseCfg %secondCfg %oldVendorCfg %merged
Далее для режима "Объединение с помощью внешней программы" выбираем "twm".

После объединения, по нажатию шестерёнки можно посмотреть результат.