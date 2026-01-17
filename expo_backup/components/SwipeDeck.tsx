import { Colors } from '@/constants/Colors';
import React from 'react';
import { Dimensions, StyleSheet, Text, TouchableOpacity, View } from 'react-native';

const { width } = Dimensions.get('window');
const CARD_WIDTH = width * 0.9;
const CARD_HEIGHT = CARD_WIDTH * 1.3;

export default function SwipeDeck() {
    return (
        <View style={styles.container}>
            {/* Background Card */}
            <View style={[styles.card, styles.cardBackground]}>
                <Text style={styles.cardTitle}>Tomorrow</Text>
            </View>

            {/* Foreground Card */}
            <View style={styles.card}>
                <Text style={styles.cardTitle}>Today's Recommendation</Text>

                {/* Illustration Placeholder */}
                <View style={styles.illustration}>
                    {/* Simple geometric representation of a person */}
                    <View style={{ width: 40, height: 40, borderRadius: 20, borderWidth: 1.5, borderColor: '#000', marginBottom: 4 }} />
                    <View style={{ width: 60, height: 90, borderWidth: 1.5, borderColor: '#000' }} />
                    <View style={{ flexDirection: 'row', gap: 4 }}>
                        <View style={{ width: 10, height: 80, borderWidth: 1.5, borderColor: '#000' }} />
                        <View style={{ width: 10, height: 80, borderWidth: 1.5, borderColor: '#000' }} />
                    </View>
                </View>

                <Text style={styles.styleLabel}>Business Professional</Text>

                <TouchableOpacity style={styles.button}>
                    <Text style={styles.buttonText}>View Details</Text>
                </TouchableOpacity>
            </View>
        </View>
    );
}

const styles = StyleSheet.create({
    container: {
        flex: 1,
        alignItems: 'center',
        justifyContent: 'center',
        marginTop: 20,
    },
    card: {
        width: CARD_WIDTH,
        height: CARD_HEIGHT,
        backgroundColor: '#fff',
        borderRadius: 32,
        padding: 24,
        alignItems: 'center',
        justifyContent: 'space-between',
        shadowColor: '#000',
        shadowOffset: { width: 0, height: 12 },
        shadowOpacity: 0.1,
        shadowRadius: 24,
        elevation: 10,
        borderWidth: 1,
        borderColor: 'rgba(0,0,0,0.02)',
    },
    cardBackground: {
        position: 'absolute',
        transform: [{ scale: 0.95 }, { translateY: 20 }],
        zIndex: -1,
        opacity: 0.5,
    },
    cardTitle: {
        fontSize: 20,
        fontWeight: '600',
        color: Colors.light.text,
        alignSelf: 'flex-start',
    },
    illustration: {
        flex: 1,
        justifyContent: 'center',
        alignItems: 'center',
        width: '100%',
    },
    styleLabel: {
        fontSize: 16,
        color: Colors.light.textSecondary,
        marginBottom: 16,
        fontWeight: '500',
    },
    button: {
        width: '100%',
        paddingVertical: 16,
        backgroundColor: Colors.light.tint,
        borderRadius: 9999,
        alignItems: 'center',
    },
    buttonText: {
        color: '#fff',
        fontSize: 16,
        fontWeight: '600',
    },
});
