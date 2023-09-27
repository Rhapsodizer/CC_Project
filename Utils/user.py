from Utils.error_manager import ErrorWindow

class User:
    def __init__(self, user_name_surname):
        self.u = user_name_surname

    def get_user_paths(self):
        u_paths = ""
        if self.u == "SA":
            u_paths = [
                        "/home/silvio/Documenti/Poli/processing42/processing-java",
                        "/home/silvio/Documenti/Poli/CC_Project/LayerInteraction",
                        "/home/silvio/Documenti/Poli/CC_Project/Instruments/MDM_MinimalisticDrumMachine",
                        "/home/silvio/Documenti/Poli/CC_Project/Instruments/Chat"
                        ]
        elif self.u == "AG":
            u_paths = [
                        "\"H:\\Software\\processing\\processing-java\"",
                        "\"H:\\Documenti\\POLIMI\\\\2_1\\CC\\Project\\GitHub\\CC_Project\\LayerInteraction\"",
                        "\"H:\\Documenti\\POLIMI\\\\2_1\\CC\\Project\\GitHub\\CC_Project\\Instruments\\MDM_MinimalisticDrumMachine\"",
                        "\"H:\\Documenti\\POLIMI\\\\2_1\\CC\\Project\\GitHub\\CC_Project\\Instruments\\Chat\""
                        ]
        elif self.u == "RM":
            u_paths = [
                        "processing-java",
                        "/Users/rischo95/Documents/STUDIO/POLIMI/MAGISTRALE/SECONDO_ANNO/PRIMO_SEMESTRE/CREATIVE_PROGRAMMING_AND_COMPUTING/CC_Project/LayerInteraction",
                        "/Users/rischo95/Documents/STUDIO/POLIMI/MAGISTRALE/SECONDO_ANNO/PRIMO_SEMESTRE/CREATIVE_PROGRAMMING_AND_COMPUTING/CC_Project/Instruments/MDM_MinimalisticDrumMachine",
                        "/Users/rischo95/Documents/STUDIO/POLIMI/MAGISTRALE/SECONDO_ANNO/PRIMO_SEMESTRE/CREATIVE_PROGRAMMING_AND_COMPUTING/CC_Project/Instruments/Chat"
                        ]
        else:
            ErrorWindow("User Error", "User name is unknown")

        return u_paths
