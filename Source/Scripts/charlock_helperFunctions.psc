ScriptName charlock_helperFunctions
{This script contains a plethora of helper functions for use throughout the plugin.}

Static Property XMarker Auto;

;
; This function was modified from the helpful comment of Xander9009 in this Creation Kit Wiki
; discussion thread:
; https://www.creationkit.com/index.php?title=Talk:GetDialogueTarget_-_Actor
;
; The purpose of this function is to return an array of actors near to the player.
; It will continue either until the requested actor count is reached, or until it has
; exhausted all actors in the given radius.
;
Actor[] function GetNearbyActors(int akActorCount = 20, float fRadius = 500.00, int iStep = 5) global
    Actor kPlayerRef = Game.GetPlayer();
    Actor[] kTargetRef = new Actor[akActorCount];
    Actor kNthRef = None;

    Cell kCell = kPlayerRef.GetParentCell();
    int iType = 43; kNPC = 43
    int iIndex = kCell.GetNumRefs(iType);
    int iActorIndex = -1;
    int Degrees = 360;

    while iActorIndex < akActorCount
        iActorIndex += 1;

        while iIndex
            iIndex -= 1;
            kNthRef = kCell.GetNthRef(iIndex, iType) as Actor;
            if kNthRef != kPlayerRef
                kTargetRef[iActorIndex] = kNthRef;
                iActorIndex += 1;
            endIf
        endWhile

        if iActorIndex < akActorCount
            ObjectReference kXMarker = kPlayerRef.PlaceAtMe(XMarker);
            Cell[] kCellA = New Cell[10];
            kCellA[0] = kCell;
            kXMarker.MoveTo(kPlayerRef, fRadius);
            iIndex = kCellA.Length;
            while Degrees > 0 && iActorIndex < akActorCount
                while iIndex
                    iIndex -= 1;
                    if kCellA[iIndex] == kxMarker.GetParentCell()
                        iIndex = -1;
                    endIf
                endWhile

                if iIndex != -1
                    iIndex = 0;
                    int iEmptyIndex;

                    while iIndex < kCellA.Length && !iEmptyIndex
                        if !kCellA[iIndex]
                            iEmptyIndex = iIndex;
                        endIf
                        iIndex += 1;
                    endWhile

                    kCellA[iEmptyIndex] = kXMarker.GetParentCell();
                    iIndex = kCell.GetNumRefs(iType);

                    while iIndex && iActorIndex < akActorCount
                        iIndex -= 1;
                        kNthRef = kCell.GetNthRef(iIndex, iType) as Actor;
                        if kNthRef != kPlayerRef
                            kTargetRef[iActorIndex] = kNthRef;
                        endIf
                    endWhile
                endIf

                Degrees -= iStep;
                float PosX = Math.Cos(Degrees) * fRadius;
                float PosY = Math.Cos(Degrees) * fRadius;
                kXMarker.MoveTo(kPlayerRef, PosX, PosY);
            endWhile
            kXMarker.Delete()
        endIf
        if Degrees <= 0 && iActorIndex < akActorCount
            iActorIndex = akActorCount;
        endIf
    endWhile
    return kTargetRef;
endFunction