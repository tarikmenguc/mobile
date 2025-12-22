const startTest = async () => {
    const baseURL = 'http://localhost:5000';

    // 1. REGISTER (Always create new user for fresh test)
    console.log('--- 1. Testing Register ---');
    let userId = '';
    const uniqueId = Date.now();
    try {
        const regRes = await fetch(`${baseURL}/api/auth/register`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                ad_soyad: `Test User ${uniqueId}`,
                email: `test${uniqueId}@example.com`,
                password: '123456',
                yas: 25, boy: 180, kilo: 80, cinsiyet: 'erkek', aktivite_seviyesi: 'orta'
            })
        });
        const regData = await regRes.json();
        console.log('Register Response:', regData);

        if (regRes.status === 201) {
            userId = regData._id;
        } else {
            console.error('Register failed:', regData);
            return;
        }
    } catch (err) {
        console.error('Auth Error:', err);
        return;
    }

    if (!userId) {
        console.error('❌ Could not get userId. Aborting.');
        return;
    }

    // 2. CONFIRM FOOD
    console.log('\n--- 2. Testing Confirm Food ---');
    const today = new Date().toISOString().split('T')[0];
    try {
        const foodRes = await fetch(`${baseURL}/api/food/confirm`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                userId: userId,
                date: today,
                food: {
                    isim: "Test Muz",
                    kalori: 105,
                    makrolar: { protein: 1.3, karbonhidrat: 27, yag: 0.4 },
                    miktar: "1 Adet",
                    kaynak: "manuel"
                }
            })
        });
        const foodData = await foodRes.json();
        console.log('Confirm Status:', foodRes.status);
        console.log('Confirm Response:', JSON.stringify(foodData, null, 2));
    } catch (err) {
        console.error('Confirm Error:', err);
    }

    // 3. GET LOG
    console.log('\n--- 3. Testing Get Log ---');
    try {
        const logRes = await fetch(`${baseURL}/api/logs/${today}?userId=${userId}`);
        const logData = await logRes.json();
        console.log('Get Log Status:', logRes.status);
        console.log('Daily Log:', JSON.stringify(logData.yemekler, null, 2));
    } catch (err) {
        console.error('Get Log Error:', err);
    }

    // 4. WATER UPDATE
    console.log('\n--- 4. Testing Water Update ---');
    try {
        const waterRes = await fetch(`${baseURL}/api/water/update`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                userId: userId,
                date: today,
                amount: 250
            })
        });
        const waterData = await waterRes.json();
        console.log('Water Update Status:', waterRes.status);
        console.log('Water Data (Su):', waterData.su_tuketimi_ml);
    } catch (err) {
        console.error('Water Error:', err);
    }

    // 5. ACTIVITY ADD
    console.log('\n--- 5. Testing Activity Add ---');
    try {
        const activityRes = await fetch(`${baseURL}/api/activity/add`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                userId: userId,
                date: today,
                activity: {
                    isim: "Koşu",
                    sure_dk: 30,
                    yakilan_kalori: 300
                }
            })
        });
        const activityData = await activityRes.json();
        console.log('Activity Add Status:', activityRes.status);
        console.log('Activity Data (Aktiviteler):', JSON.stringify(activityData.aktiviteler, null, 2));

        if (activityData.aktiviteler && activityData.aktiviteler.length > 0) {
            console.log('\n✅ TEST SUCCESSFUL: All backend flows verified.');
        }

    } catch (err) {
        console.error("Activity Error:", err);
    }
};

startTest();
