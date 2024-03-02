unit MBSoft.System.Generics.Collections;
//****************************************************************************
//Aggiunte alla unit System.Generics.Collections
//
//Copyright MBSoft (2021)
//****************************************************************************

interface

uses
  System.Generics.Collections;

//Un elemento che può avere lo stato selezionato o no
type
  TMBCheckedItem<T> = class
  private
    FValue: T;
    FChecked: Boolean;
  public
    constructor Create(aValue: T; aChecked: Boolean = false);

    //Inverte lo stato dell' elemento
    procedure Toggle;

    //Seleziona o deseleziona l' elemento
    procedure Check;
    procedure UnCheck;

    property Value: T read FValue write FValue;
    property Checked: Boolean read FChecked write FChecked;
  end;

  TMBCheckedList<T> = class(TObjectList<TMBCheckedItem<T>>)
  end;

implementation

{ TMBCheckedItem<T> }

procedure TMBCheckedItem<T>.Check;
begin
  Checked:=true;
end;

constructor TMBCheckedItem<T>.Create(aValue: T; aChecked: Boolean);
begin
  Value:=aValue;
  Checked:=aChecked;
end;

procedure TMBCheckedItem<T>.Toggle;
begin
  Checked:=not Checked;
end;

procedure TMBCheckedItem<T>.UnCheck;
begin
  Checked:=false;
end;

end.
