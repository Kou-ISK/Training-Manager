//
//  CustomCalendarView.swift
//  Training Manager
//
//  Created by 井坂航 on 2024/09/23.
//

import SwiftUI

// カスタムカレンダーのビュー
struct CustomCalendarView: View {
    @Binding var selectedDate: Date
    var sessionDates: [Date]
    
    // カレンダーの週や月を作成するために必要なヘルパー
    let calendar = Calendar.current
    
    // 現在の月の全日付を取得
    var daysInMonth: [Date] {
        guard let range = calendar.range(of: .day, in: .month, for: selectedDate) else {
            return []
        }
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: selectedDate))!
        return range.compactMap { day -> Date? in
            return calendar.date(byAdding: .day, value: day - 1, to: startOfMonth)
        }
    }
    
    var body: some View {
        VStack {
            // カレンダーの月と年の表示
            HStack {
                Button(action: {
                    // 前の月へ移動
                    selectedDate = calendar.date(byAdding: .month, value: -1, to: selectedDate) ?? selectedDate
                }) {
                    Image(systemName: "chevron.left")
                }
                
                Text(selectedDate, formatter: yearMonthFormatter)
                    .font(.headline)
                    .padding(.horizontal)
                
                Button(action: {
                    // 次の月へ移動
                    selectedDate = calendar.date(byAdding: .month, value: 1, to: selectedDate) ?? selectedDate
                }) {
                    Image(systemName: "chevron.right")
                }
            }
            
            // カレンダーの曜日ヘッダー
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7)) {
                ForEach(calendar.shortWeekdaySymbols, id: \.self) { day in
                    Text(day).font(.subheadline).bold()
                }
            }
            
            // カレンダーの日付を表示
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7)) {
                ForEach(daysInMonth, id: \.self) { day in
                    VStack {
                        ZStack {
                            // セッションがある日付は赤い丸でマーク
                            let sessionCount = sessionDates.filter { calendar.isDate($0, inSameDayAs: day) }.count
                            ForEach(0..<sessionCount, id: \.self) { index in
                                Circle()
                                    .stroke(.red)
                                    .frame(width: 6, height: 6)
                                    .offset(x: sessionCount == 1 ? 0 : CGFloat(index) * 8 - (CGFloat(sessionCount) * 4), y: 15) // オフセットを調整
                            }
                            
                            // 本日日付の強調表示
                            if calendar.isDateInToday(day) {
                                Circle()
                                    .foregroundStyle(Color.blue).opacity(0.4)
                                    .frame(width: 30, height: 30)
                            }
                            
                            // 日付のテキスト
                            Text("\(calendar.component(.day, from: day))")
                                .font(.system(size: 16)) // フォントサイズを16に設定
                                .foregroundColor(calendar.isDate(day, inSameDayAs: selectedDate) || calendar.isDateInToday(day) ? .white : .primary)
                                .frame(width: 20, height: 20) // 円と同じサイズのフレームを指定
                                .padding(4)
                                .background(
                                    calendar.isDate(day, inSameDayAs: selectedDate) ? Color.blue : Color.clear
                                )
                                .clipShape(Circle())
                                .onTapGesture {
                                    // 日付がタップされたときに選択
                                    selectedDate = day
                                }
                        }
                    }
                }
            }
        }
        .padding(10)
    }
}

#Preview {
    CustomCalendarView(
        selectedDate: .constant(Date()),
        sessionDates: [
            Date(),
            Calendar.current.date(byAdding: .day, value: -1, to: Date())!,
            Calendar.current.date(byAdding: .day, value: -1, to: Date())!,
            Calendar.current.date(byAdding: .day, value: +3, to: Date())!
        ]
    )
}
