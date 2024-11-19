create trigger BEFORE_INSERT_UPDATE_FIRMA_TRIGGER
    before insert or update
    on FIRMA
    for each row
DECLARE
  v_count NUMBER;
BEGIN
  -- Sprawdzamy, czy nowy NIP już istnieje
  SELECT COUNT(*)
  INTO v_count
  FROM Firma
  WHERE NIP = :NEW.NIP AND :NEW.IdFirma IS NULL; -- Dodajemy warunek dla INSERT

  IF v_count > 0 THEN
    RAISE_APPLICATION_ERROR(-20003, 'Firma o podanym NIP już istnieje!');
  END IF;

  -- Sprawdzamy, czy nowa Nazwa już istnieje
  SELECT COUNT(*)
  INTO v_count
  FROM Firma
  WHERE UPPER(Nazwa) = UPPER(:NEW.Nazwa) AND :NEW.IdFirma IS NULL; -- Dodajemy warunek dla INSERT

  IF v_count > 0 THEN
    RAISE_APPLICATION_ERROR(-20004, 'Firma o podanej nazwie już istnieje!');
  END IF;
END;
/

