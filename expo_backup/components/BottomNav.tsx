import { Colors } from '@/constants/Colors';
import { Feather } from '@expo/vector-icons';
import React from 'react';
import { Dimensions, StyleSheet, TouchableOpacity, View } from 'react-native';

const { width } = Dimensions.get('window');

export default function BottomNav() {
    return (
        <View style={styles.container}>
            <TouchableOpacity>
                <Feather name="home" size={24} color={Colors.light.text} />
            </TouchableOpacity>

            <TouchableOpacity>
                <Feather name="columns" size={24} color={Colors.light.textSecondary} />
                {/* "columns" as Wardrobe/Doorish? Or "grid"? "layout"? 
            Let's use "grid" or "box" if available. Feather has "sidebar"? 
            Let's use "layout". */}
            </TouchableOpacity>

            <TouchableOpacity style={styles.plusButton} activeOpacity={0.9}>
                <Feather name="plus" size={28} color={Colors.light.textInverse} />
            </TouchableOpacity>

            <TouchableOpacity>
                <Feather name="search" size={24} color={Colors.light.textSecondary} />
            </TouchableOpacity>

            <TouchableOpacity>
                <Feather name="user" size={24} color={Colors.light.textSecondary} />
            </TouchableOpacity>
        </View>
    );
}

const styles = StyleSheet.create({
    container: {
        position: 'absolute',
        bottom: 0,
        left: 0,
        width: width,
        height: 90, // Include safe area logic usually, but fixed for now
        backgroundColor: 'rgba(255,255,255,0.95)',
        flexDirection: 'row',
        justifyContent: 'space-evenly',
        alignItems: 'flex-start',
        paddingTop: 20,
        borderTopWidth: 1,
        borderTopColor: 'rgba(0,0,0,0.05)',
    },
    plusButton: {
        width: 56,
        height: 56,
        borderRadius: 28,
        backgroundColor: Colors.light.tint, // Black
        justifyContent: 'center',
        alignItems: 'center',
        marginTop: -28, // Pull up
        shadowColor: '#000',
        shadowOffset: { width: 0, height: 8 },
        shadowOpacity: 0.2,
        shadowRadius: 10,
        elevation: 8,
    },
});
