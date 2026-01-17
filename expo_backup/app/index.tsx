import BottomNav from '@/components/BottomNav';
import DateSelector from '@/components/DateSelector';
import SwipeDeck from '@/components/SwipeDeck';
import { Colors } from '@/constants/Colors';
import { Platform, SafeAreaView, StatusBar, StyleSheet, View } from 'react-native';

export default function Dashboard() {
    return (
        <SafeAreaView style={styles.container}>
            <DateSelector />
            <View style={styles.content}>
                <SwipeDeck />
            </View>
            <BottomNav />
        </SafeAreaView>
    );
}

const styles = StyleSheet.create({
    container: {
        flex: 1,
        backgroundColor: Colors.light.background,
        paddingTop: Platform.OS === 'android' ? StatusBar.currentHeight : 0,
    },
    content: {
        flex: 1,
        justifyContent: 'center',
        marginBottom: 90, // Space for BottomNav
    },
});
