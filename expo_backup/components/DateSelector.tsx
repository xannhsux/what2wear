import { Colors } from '@/constants/Colors';
import React from 'react';
import { StyleSheet, Text, TouchableOpacity, View } from 'react-native';
// We need an icon library. Expo comes with @expo/vector-icons
// Wait, lucide-react-native needs to be installed or I use @expo/vector-icons.
// The user prompt implies I used lucide-react before. I should install lucide-react-native and react-native-svg
// Or just use @expo/vector-icons (Feather/Ionicons) which is built-in.
// I will use lucide-react-native for consistency if I install it, but purely for speed/stability I'll use @expo/vector-icons
// actually "Feather" has "briefcase".

import { Feather } from '@expo/vector-icons';

export default function DateSelector() {
    return (
        <View style={styles.container}>
            {/* Date Pill */}
            <TouchableOpacity style={styles.datePill} activeOpacity={0.9}>
                <Text style={styles.weekday}>Friday</Text>
                <Text style={styles.date}>Jan 16</Text>
            </TouchableOpacity>

            {/* Event Label */}
            <View style={styles.eventLabel}>
                <Feather name="briefcase" size={16} color={Colors.light.text} />
                <Text style={styles.eventText}>Work Day – Office</Text>
            </View>
        </View>
    );
}

const styles = StyleSheet.create({
    container: {
        alignItems: 'center',
        paddingVertical: 20,
        gap: 16,
        width: '100%',
    },
    datePill: {
        flexDirection: 'row',
        alignItems: 'center',
        justifyContent: 'space-between',
        backgroundColor: Colors.light.tint, // Black
        paddingVertical: 14,
        paddingHorizontal: 24,
        borderRadius: 9999,
        width: '90%',
        maxWidth: 380,
        shadowColor: '#000',
        shadowOffset: { width: 0, height: 4 },
        shadowOpacity: 0.1,
        shadowRadius: 8,
        elevation: 4,
    },
    weekday: {
        fontSize: 28,
        fontWeight: '700',
        color: Colors.light.textInverse, // White
        letterSpacing: -0.5,
    },
    date: {
        fontSize: 16,
        color: Colors.light.textInverse,
        opacity: 0.8,
    },
    eventLabel: {
        flexDirection: 'row',
        alignItems: 'center',
        gap: 8,
        backgroundColor: '#fff',
        paddingVertical: 10,
        paddingHorizontal: 20,
        borderRadius: 9999,
        borderWidth: 1,
        borderColor: 'rgba(0,0,0,0.05)',
    },
    eventText: {
        fontSize: 14,
        fontWeight: '600',
        color: Colors.light.text,
    },
});
