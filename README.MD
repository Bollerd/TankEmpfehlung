# Tank Empfehlung

Meine Tankempfehlung überwacht für uns die wichtigsten Tankstellen und gibt uns eine Rückmeldung, ob es sich momentan lohnt zu tanken oder nicht. Die App ist vermutlich nicht für andere 1:1 direkt verwendbar, es sei denn, ihr wohnt in der gleichen Region wie wir. Denn für die Daten der App wird zusätzlich noch eine nodeJS Anwendung benötigt, die die Tankstellenpreise abfragt und historisch in einer PostgreSQL Datenbank speichert und die Daten für die App zusätzlich noch auf einem Webserver zur Verfügung stellt.

In der App kann gewählt werden welche Spritsorte angezeigt werden soll: E5, E10 oder Diesel. Und für welche Region, da wir entweder zuhause tanken, in Heidelberg oder bei Wörth.

Die App zeigt für die gewählte Spritsorte dann die Tankstellen der gewählten Region an mit dem aktuellen Preis sowie dem höchsten/niedrigsten Preis für alle Tankstelle pro Tag (für die letzten zwei Wochen). Ist der Preis eindeutig zu hoch oder niedrig wird die Tankstelle direkt farblich markiert. In orange kann es sich durchaus trotzdem lohnen zu tanken, weil es eventuell nur 1 oder 2 Cent teurer ist und generell der Preistrend die letzten Tage in die Höhe geht.

Tippt man auf die Historie, bekommt man einen grafischen Verlauf der Preise für die letzten 14 Tage und bei Tip auf die Tankstelle wird die Tankstelle auf einer Karte angezeigt.

In den Einstellungen ist eine Sprachansage aktivierbar, um zB für Motorradfahrer nach "Siri öffne Tank Empfehlung" eine Sprachansage über die aktuelle Preissituation zu erhalten.

## Technische Informationen

Für die Daten wird die Tankerkönig API verwendet. Von dort werden über eine nodeJS Anwendung ca alle 30 Minuten die für uns interessanten Tankstellen abgefragt und in einer PostgreSQL Datenbank abgespeichert. Hier sind die Daten historisch gespeichert. Für die notwendigen Daten der App werden dann JSON Dateien erstellt und per SFTP auf einen Webserver hochgeladen über den die App sich dann ihre aktuellen Daten holen kann. Dieses komplette nodeJS Backend und SFTP Upload auf einen Webserver müsste man für eigene andere Regionen oder Tankstellen ebenfalls programmieren.

## Notwendige Anpassungen
Die App kann mit dem vorhandenen Code aus Github direkt 1:1 verwendet werden. Allerdings mit der Einschränkung, dass nur die Regionen und Tankstellen verwendet werden können, die auch wir nutzen. Sollen eigene Regionen und Tankstellen benutzt werden, so muss die URL von der die Daten gelesen werden korrigiert werden und diese Daten müssen dann auch selbst bereitgestellt werden. Dazu ist die Variable REMOTE_HOST in der Datei Constants anzupassen.

Welche Regionen die App benutzen kann, ist im Enum LocationGroups in der Datei DataDefinitions hinterlegt. Wichtig: die Enum Vertextung muss Attribut group aus der bereitgestellten Datendatei "getGasStations.json", stationGroup der Dateidatei "getCurrentGasPrices.json" bzw locationGroup der Dateidatei "getGasPricesHistory.json" entsprechen.

Sollen andere Spritarten wie E5, E10 und Diesel verwaltet werden, so ist der Enum GasTypes in der Datei DataDefinitions anzupassen. Dies erfordert jedoch nicht nur Anpassungen an Stellen wie für die Gruppen zuvor beschrieben, sondern noch wesentlich weitreichendere Korrekturen, da es auch berechnete Attribute wie max_e5 oder min_e5 gibt die ebenfalls dann entsprechend erstellt oder angepasst werden müssen.

## App Screenshots

### Übersicht
![Übersicht](https://ios.dbweb.info/wp-content/uploads/2024/11/tank1-scaled.jpg)

### Tankstellen Geoposition
![Tankstellen Geoposition](https://ios.dbweb.info/wp-content/uploads/2024/11/tank2-scaled.jpg)

### Historische Preisentwicklung
![Historische Preisentwicklung](https://ios.dbweb.info/wp-content/uploads/2024/11/tank3-scaled.jpg)

### Einstellungen
![Einstellungen](https://ios.dbweb.info/wp-content/uploads/2024/11/tank4-scaled.jpg)
