unit MBSoft.CheckMem;
//******************************************************************************
//Controlla se l'applicazione termina con la memoria dinamica a 0, ovvero se
//tutti i blocchi usati vengono rilasciati/distrutti correttamente.
//Va inserita prima di tutte le altre unità in modo che venga caricata per
//prima e rilasciata per ultima.
//
//Non è farina del mio sacco ma l'ho trovata nel libro "Programmare in Delphi 7"
//di Marco Cantù
//
//Codice originale scritto per Delphi 7 e poi aggiornato a Delphi 10.1 (Berlin)
//******************************************************************************

interface

implementation

uses
  Windows;

const
  //Stringhe per la finestra di messaggio
  MSG_TITLE = 'Memoria non liberata correttemente';
  MSG_HEAD = 'Alcuni blocchi di memoria non sono stati scaricati correttamente.'+
    #13#10+'Ciò può dipendere da oggetti non distrutti o da variabili dinamiche'+
    #13#10+'non finalizzate.';
  MSG_MEMCOUNT = ' Blocchi rimasti';
  MSG_MEMSIZE = ' Byte(s) allocati';

var
  MCount,MSize: String[10];
  Msg: String;

initialization

finalization
  if (AllocMemCount>0) or (AllocMemSize>0) then
  begin
    Str(AllocMemCount,MCount);
    Str(AllocMemSize,MSize);
    Msg:=MSG_HEAD+#13#10#13#10+
      MCount+MSG_MEMCOUNT+#13#10+
      MSize+MSG_MEMSIZE;
    MessageBox(0,PChar(Msg),MSG_TITLE,MB_OK)
  end
end.
 