function bool = hasConflicts(prel, pred, curl, curd)
bool = 0;

switch mod(pred - prel, 4)
    case 2 % go straight
        if mod(curl, 4) == mod(prel + 1, 4) && mod(curd - curl, 4) ~= 1
            bool = 1;
        else
            if mod(curl, 4) == mod(prel + 2, 4) && mod(curd - curl, 4) == 3
                bool = 1;
            else
                if mod(curl, 4) == mod(prel + 3, 4) && mod(curd - curl, 4) == 2
                    bool = 1;
                end
            end
        end
    case 3 % left turn
        if mod(curl, 4) == mod(prel + 1, 4) && mod(curd - curl, 4) == 3
            bool = 1;
        else
            if mod(curl, 4) == mod(prel + 2, 4) && mod(curd - curl, 4) == 2
                bool = 1;
            else
                if mod(curl, 4) == mod(prel + 3, 4) && mod(curd - curl, 4) ~= 1
                    bool = 1;
                end
            end
        end
end

end