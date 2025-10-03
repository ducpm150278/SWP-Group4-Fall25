/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package entity;

/**
 *
 * @author admin
 */
public class Language {
    private int languageID;
    private String languageName;

    public Language(int languageID, String languageName) {
        this.languageID = languageID;
        this.languageName = languageName;
    }

    public int getLanguageID() {
        return languageID;
    }

    public String getLanguageName() {
        return languageName;
    }
}
