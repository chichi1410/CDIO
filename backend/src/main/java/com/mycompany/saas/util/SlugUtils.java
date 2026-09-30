package com.mycompany.saas.util;

import java.text.Normalizer;
import java.util.Locale;
import java.util.regex.Pattern;

public final class SlugUtils {

    private static final Pattern NONLATIN = Pattern.compile("[^\\w-]");
    private static final Pattern WHITESPACE = Pattern.compile("[\\s]+");
    private static final Pattern EDGES_DASHES = Pattern.compile("(^-+|-+$)");
    private static final Pattern MULTI_DASHES = Pattern.compile("-+");

    private SlugUtils() {
    }

    public static String toSlug(String input) {
        if (input == null || input.isBlank()) {
            return "";
        }

        // Replace Vietnamese 'đ', 'Đ'
        String result = input.replace('đ', 'd').replace('Đ', 'D');

        // Decompose diacritics
        String nowhitespace = WHITESPACE.matcher(result.trim()).replaceAll("-");
        String normalized = Normalizer.normalize(nowhitespace, Normalizer.Form.NFD);
        Pattern diacritics = Pattern.compile("\\p{InCombiningDiacriticalMarks}+");
        String slug = diacritics.matcher(normalized).replaceAll("");

        // Strip non-latin characters
        slug = NONLATIN.matcher(slug).replaceAll("");
        slug = MULTI_DASHES.matcher(slug).replaceAll("-");
        slug = EDGES_DASHES.matcher(slug).replaceAll("");

        return slug.toLowerCase(Locale.ENGLISH);
    }
}
