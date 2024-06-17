import Cookies from 'js-cookie';

export const getUserClassFromCookies = () => {
    return Cookies.get('userClass');
};

export const setUserClassInCookies = (userClass) => {
    Cookies.set('userClass', userClass, { expires: 2 });
};

export const getUserNameFromCookies = () => {
    return Cookies.get('userName');
};

export const setUserNameInCookies = (userName) => {
    Cookies.set('userName', userName, { expires: 2 });
};

export const getFactionFromCookies = () => {
    return Cookies.get('userFaction');
};

export const setFactionInCookies = (userFaction) => {
    Cookies.set('userFaction', userFaction, { expires: 2 });
};

export const resetCookies = ()=>{
    Cookies.remove('userName');
    Cookies.remove('userClass');
    Cookies.remove('userFaction');
}
